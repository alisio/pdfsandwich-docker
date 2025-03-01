#!/bin/bash

# Parse arguments to allow pdfsandwich options in any order and extract input/output paths
OUTPUT_FILE=""
INPUT_FILE=""
# Array to accumulate options (except input/output paths) to pass to pdfsandwich
container_args=()

# Copy all arguments for parsing
ARGS=("$@")
num_args=${#ARGS[@]}

# Loop through arguments to identify -o (output) and input file
i=0
while [ $i -lt $num_args ]; do
    arg="${ARGS[i]}"
    case "$arg" in
        --)
            # End of options marker. The next argument (if any) should be the input file.
            i=$((i+1))
            if [ $i -lt $num_args ] && [ -z "$INPUT_FILE" ]; then
                INPUT_FILE="${ARGS[i]}"
                i=$((i+1))
            fi
            break  # stop processing further options
            ;;
        -o)
            # Output file specified
            if [ $((i+1)) -lt $num_args ]; then
                OUTPUT_FILE="${ARGS[i+1]}"
                i=$((i+2))   # skip the output file argument as well
                # Do not add -o or its argument to container_args here (will handle after mapping paths)
                continue
            else
                # "-o" given without an output filename (not validating, just skipping)
                i=$((i+1))
                break
            fi
            ;;
        # Options that expect a value: add the option and its value, then skip the value in the loop
        -convert|-coo|-first_page|-gs|-hocr2pdf|-hoo|-identify|-last_page|-lang|-layout|-nthreads|-pagesize|-resolution|-tesseract|-tesso|-unpaper|-unpo)
            container_args+=("$arg")
            if [ $((i+1)) -lt $num_args ]; then
                container_args+=("${ARGS[i+1]}")
                i=$((i+2))   # skip over the value after the option
            else
                i=$((i+1))
            fi
            continue
            ;;
        # Options that do NOT take a value: add as-is
        -help|--help|-version|-debug|-enforcehocr2pdf|-grayfilter|-sloppy_text|-rgb|-quiet|-verbose)
            container_args+=("$arg")
            i=$((i+1))
            continue
            ;;
        *)
            # Any other argument (could be an unknown flag or the input file)
            if [[ "$arg" == -* ]]; then
                # Unrecognized option flag – pass it through to pdfsandwich
                container_args+=("$arg")
            else
                # Non-flag argument – treat as input file (if one isn't already set)
                if [ -z "$INPUT_FILE" ]; then
                    INPUT_FILE="$arg"
                else
                    echo "Warning: Multiple input files detected. Using '$INPUT_FILE', ignoring '$arg'." >&2
                fi
            fi
            i=$((i+1))
            continue
            ;;
    esac
done

# If no input file has been set yet and there is one more argument, take it as the input file
if [ -z "$INPUT_FILE" ] && [ $i -lt $num_args ]; then
    INPUT_FILE="${ARGS[i]}"
fi

# Require an input file to proceed
if [ -z "$INPUT_FILE" ]; then
    echo "Error: No input PDF file specified." >&2
    exit 1
fi

# Resolve absolute path of the input file
PDF_FILE="$(realpath "$INPUT_FILE")"
PDF_DIR="$(dirname "$PDF_FILE")"
PDF_NAME="$(basename "$PDF_FILE")"

# Prepare Docker volume mappings and container paths
if [ -n "$OUTPUT_FILE" ]; then
    # Resolve output path to absolute (without validating existence)
    case "$OUTPUT_FILE" in
        /*) OUTPUT_ABS="$OUTPUT_FILE" ;;
        *) OUTPUT_ABS="$(realpath -m "$OUTPUT_FILE")" ;;
    esac
    OUTPUT_DIR="$(dirname "$OUTPUT_ABS")"
    OUTPUT_NAME="$(basename "$OUTPUT_ABS")"
    if [ "$OUTPUT_DIR" != "$PDF_DIR" ]; then
        # Different input/output directories: mount both
        VOLUMES=(-v "$PDF_DIR:/data_in" -v "$OUTPUT_DIR:/data_out")
        INPUT_PATH_IN_CONTAINER="/data_in/$PDF_NAME"
        OUTPUT_PATH_IN_CONTAINER="/data_out/$OUTPUT_NAME"
    else
        # Same directory for input and output
        VOLUMES=(-v "$PDF_DIR:/data")
        INPUT_PATH_IN_CONTAINER="/data/$PDF_NAME"
        OUTPUT_PATH_IN_CONTAINER="/data/$OUTPUT_NAME"
    fi
else
    # Only input directory (output will be default in the same folder)
    VOLUMES=(-v "$PDF_DIR:/data")
    INPUT_PATH_IN_CONTAINER="/data/$PDF_NAME"
fi

# Build and run the Docker command
if [ -n "$OUTPUT_FILE" ]; then
    docker run --rm "${VOLUMES[@]}" alisio/pdfsandwich-docker \
        "${container_args[@]}" "$INPUT_PATH_IN_CONTAINER" -o "$OUTPUT_PATH_IN_CONTAINER"
else
    docker run --rm "${VOLUMES[@]}" alisio/pdfsandwich-docker \
        "${container_args[@]}" "$INPUT_PATH_IN_CONTAINER"
fi
