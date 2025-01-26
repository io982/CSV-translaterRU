# CSV-translaterRU

bash script that translate target column of csv-file. Used Yandex cloud

### Using

translate.sh ...arguments

**$1** <= target_csv_file\
**$2** <= yandex_cloud_API_KEY\
**$3** <= yandex_cloud_FOLDER_ID\
**$4** <= column_number (default 1)\
**$5** <= original_language (default "en")

**Output:** taranslate_DDMMYY.csv

### Example

```bash
./translate.sh "./test.csv" "Yandex cloud API_KEY" "b1g....Yandex cloud FOLDER_ID" 10
```

### Attention!

when using a script with the necessary funds from your payment account in the Yandex cloud

### Useful

<https://yandex.cloud/ru/docs/translate/operations/sa-api-key>\
<https://yandex.cloud/ru/docs/translate/quickstart>
