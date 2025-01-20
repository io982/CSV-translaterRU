#!/bin/bash

CSV_FILE=$1 #target csv 
API_KEY=$2 #Yandex cloud API_KEY
FOLDER_ID=$3 #Yandex cloud FOLDER_ID
TARGET_COLUMN=${4:-1} #target column number into CSV_FILE
SOURCE_LANG=${5:-"en"}
TARGET_LANG="ru"
TRANSLATE_URL="https://translate.api.cloud.yandex.net/translate/v2/translate"

if [ ! -f "$CSV_FILE" ]; then
  echo "Файл $CSV_FILE не найден!"
  exit 1
fi

# Функция для транслитерации
transliterate() {
  local input="$1"
  declare -A translit_table=(
    ["а"]="a" ["б"]="b" ["в"]="v" ["г"]="g" ["д"]="d"
    ["е"]="e" ["ё"]="yo" ["ж"]="zh" ["з"]="z" ["и"]="i"
    ["й"]="y" ["к"]="k" ["л"]="l" ["м"]="m" ["н"]="n"
    ["о"]="o" ["п"]="p" ["р"]="r" ["с"]="s" ["т"]="t"
    ["у"]="u" ["ф"]="f" ["х"]="kh" ["ц"]="ts" ["ч"]="ch"
    ["ш"]="sh" ["щ"]="shch" ["ъ"]="" ["ы"]="y" ["ь"]=""
    ["э"]="e" ["ю"]="yu" ["я"]="ya"
  )
  for cyr in "${!translit_table[@]}"; do
    local lat="${translit_table[$cyr]}"
    input=$(echo "$input" | sed "s/$cyr/$lat/g")
  done
  echo "$input"
}

#создание массива строк с описанием description из csv файла
texts=()

first_line=$(head -n 1 "$CSV_FILE")
# Разделяем строку по запятым и сохраняем в массив
IFS=',' read -r -a columns <<< "$first_line"
# Проверяем, что в строке есть столько колонок
if [ ${#columns[@]} -ge $TARGET_COLUMN ]; then
    # Копируем колоноки, объединяем их через пробелы и добавляем "els"
    result=$(echo "${columns[@]:0:$TARGET_COLUMN - 1}" | tr ' ' ' ')
    cols="col$result description els"
else
    echo "В строке меньше колонок."
fi

while IFS=, read -r $cols
do
  if [[ -n $col ]] then
    #проверка есть ли в строке $description двойная кавычка
    if [[ "$description" == *\"* ]]; then      
      #если есть ищем остаток строки в $els
      part_from_els=$(echo "$els" | awk -F'"' '{print $1}') 
      #если найденная часть не равна $els значит кавычка там есть склеиваем
      if [[ "$part_from_els" != "$els" ]] then
        description="$description","$part_from_els"\"
      fi          
    else 
      description=\""$description"\"
    fi 
    texts+=("$description") 
  fi
done < "$CSV_FILE"

echo ${texts[1]}
# Преобразование массива в JSON (с удалением \r)
#texts_json=$(printf '%s\n' "${texts[@]}" | tr -d '\r' | jq -R . | jq -s .)





