This folders should contain all the scripts needed to extract metric value for import.

The main four scripts:

1. step_1_get_all_snipprt.rb
2. step_2_extract_sample_metric_values.rb
3. step_3_extract_metric_values.rb
4. step_5_import_metric_value.rb

### 1. step_1_get_all_snipprt.rb
This script is for getting all the snippets from CERTH. After running it, a file called `certh.json` will appear in data folder.

### 2. step_2_extract_sample_metric_values.rb
This will generate a CSV containing a sample for every metric. This is just for you to check if things are something you need.

### 3. step_3_extract_metric_values.rb
This script needs two arguments, the raw json from CERTH and the snippet to metric name mapping csv file.

**If neccessary, some clean up scripts will be needed before prceeding to step 4**

```shell 
ruby script/step_3_extract_metric_values.rb script/metric/data/metric_snippet_mapping.csv script/metric/data/certh.json
```
It will generate a CSV having the metrics stated in the `metric_snippet_mapping.csv`.

The mapping file should contain at least four columns.
```
snippet_name, snippet_provider, designer, name
```
This script will generate a file in csv folder which is ready to be imported

### 4. step_5_import_metric_value.rb
Import a CSV to wikirate.

```shell
ruby script/import_metric_value.rb script/metric/csv/metric_to_import.csv
```