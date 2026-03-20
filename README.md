# State Fragility Prediction

## Mission
Predicting state fragility levels to enable early intervention in conflict prevention, fostering enduring peace and sustainable development. Starting with South Sudan as a case study, the model is scalable to all 176 countries covered by the Fragile States Index, providing a systematic tool for identifying governance vulnerabilities before they escalate into crisis.

## About the Data
I used the Fragile States Index dataset which covers 176 countries from 2006 to 2024. It has 12 main indicators that measure different aspects of state stability - things like security apparatus, economic decline, human rights, refugees, etc. Each indicator is scored 0-10 and they add up to a total fragility score (0-120). Higher scores mean the country is more fragile/at risk.

I got the data from Mendeley Data: https://data.mendeley.com/datasets/bhbcjtgjdm
Original source is The Fund for Peace: https://fragilestatesindex.org/

## What's in this repo
- `summative/linear_regression/multivariate.ipynb` - the main notebook with all the analysis
- `summative/linear_regression/data/` - folder for the dataset (you need to download it)
- `summative/API/` - empty for now (part 2 of the assignment)
- `summative/FlutterApp/` - empty for now (part 2 of the assignment)

## To run this
1. Download the dataset from the Mendeley link above (the Excel file)
2. Put it in `summative/linear_regression/data/data_FragileStatesIndex.xlsx`
3. Install requirements: `pip install -r requirements.txt`
4. Run the notebook

## Models I built
- Linear Regression
- Random Forest  
- Decision Tree

The Random Forest performed best based on test MSE, so that's what gets saved as the final model.

## Note
South Sudan shows up in the data from 2011 onwards (when it became independent). You can see how its fragility scores compare to other countries in the visualizations.