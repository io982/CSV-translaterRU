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

transliterate() {
  echo "$1" | sed 'y/абвгдеёжзийклмнопрстуфхцчшщъыьэюя/abvgdeejzijklmnoprstufhzcss_y_eua/'
}

#прогрессбар
total_elements=0
current_element=0

progressBar() {
  ((current_element++))
  progress=$((current_element * 100 / total_elements)) 
  printf "\rCreating JSON arrays: [%-10s] %d%%" "$(printf '#%.0s' $(seq 1 $((progress / 10))))" "$progress" 
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

subarrays=()  # Массив для хранения подмассивов
current_array=()  # Текущий подмассив
current_length=0  # Длина текущего подмассива в JSON

#для прогрессбар
total_elements=${#texts[@]}
current_element=0

for element in "${texts[@]}"; do  

  # Преобразуем текущий элемент в JSON
  element_json=$(echo -n "$element" | jq -R .)

  # Предполагаемая длина нового подмассива, если добавить текущий элемент
  new_length=$((current_length + ${#element_json} + 1))  # +1 для запятой

  # Если добавление элемента превышает лимит, сохраняем текущий подмассив и начинаем новый
  if [ "$new_length" -ge 9000 ]; then
    subarrays+=("$(printf '%s\n' "${current_array[@]}" | jq -R . | jq -s .)")
    current_array=()
    new_length=${#element_json}
  fi

  # Добавляем элемент в текущий подмассив
  current_array+=("$element")
  current_length=$new_length

  progressBar
done

# Добавляем последний подмассив, если он не пустой
if [ "${#current_array[@]}" -gt 0 ]; then
  subarrays+=("$(printf '%s\n' "${current_array[@]}" | jq -R . | jq -s .)")
fi
echo

#tests
#echo ""
# Выводим результат
#for i in "${!subarrays[@]}"; do
  #echo "Sub Arr $i: ${subarrays[$i]}"
  #echo "Sub Array $i length: ${#subarrays[$i]}"
#done
read TRANSL < <(transliterate "Товарищь майор, любит выпить водку и трахнуть красивую сотрудницу") 
echo $TRANSL

