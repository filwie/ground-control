#!/usr/bin/env bash

PDF_DIR="${1:-.}"
OUTPUT_DIR="${2:-./output}"

pushd "${PDF_DIR}" > /dev/null
for pdf_file in *.pdf; do
    if [[ -f "${pdf_file}" ]]; then
        file_name="${pdf_file##*/}"
        file_name_no_ext="${file_name%.*}"
        file_output_dir="${OUTPUT_DIR}/${file_name_no_ext}"
        [[ -d "${file_output_dir}" ]] || mkdir -p "${file_output_dir}"
        convert -density 300 "${pdf_file}" -background white -alpha background -alpha off -quality 100 "${file_output_dir}/${file_name_no_ext}.png"

        pushd "${file_output_dir}" > /dev/null
        for png_file in *.png; do
            echo "drawing rectangle on ${png_file}"
            convert "${png_file}" -fill white -stroke white -gravity south -draw "rectangle 0,0 600,50" "${png_file}"
        done
        echo "converting back to pdf"
        convert "*.png" -quality 100 "${file_name_no_ext}.pdf"
        popd > /dev/null
    fi
done
popd > /dev/null
