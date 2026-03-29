State Fragility Prediction

Mission

Predicting state fragility levels to enable early intervention in conflict prevention, fostering enduring peace and sustainable development. Starting with South Sudan as a case study, the model is scalable to all 176 countries covered by the Fragile States Index, providing a systematic tool for identifying governance vulnerabilities before they escalate into crisis.

Public API Endpoint

URL: https://fragility-api.onrender.com
Swagger Docs: https://fragility-api.onrender.com/docs
Predict Endpoint: https://fragility-api.onrender.com/predict
Health Check: https://fragility-api.onrender.com/health

Watch the demo video here

VIDEO LINK 

About the Data

I used the Fragile States Index data from The Fund for Peace covering 2019-2023 (5 years). Each year has data for 176 countries with 12 indicators that measure different aspects of state stability - security apparatus, economic decline, human rights, refugees, etc. Each indicator is scored 0-10 and they add up to a total fragility score (0-120). Higher scores mean the country is more fragile/at risk.

The data is already included in the repo as 5 separate Excel files (fsi-2019.xlsx through fsi-2023.xlsx) since the full historical dataset didn't have the individual indicators broken down.

Source: https://fragilestatesindex.org/

What's in this repo

summative/linear_regression/multivariate.ipynb - the main notebook with all the analysis and models
summative/linear_regression/data/ - contains the 5 Excel files (2019-2023)
summative/linear_regression/data_visualizations.png - correlation heatmap and distributions
summative/linear_regression/loss_curves.png - training and test loss curves
summative/linear_regression/regression_fit.png - scatter plot showing regression line
summative/linear_regression/best_fragility_model.pkl - saved best model
summative/API/main.py - FastAPI application with prediction and retrain endpoints
summative/API/prediction.py - model loading and prediction logic
summative/API/requirements.txt - API dependencies
summative/FlutterApp/lib/main.dart - Flutter mobile app code
summative/FlutterApp/pubspec.yaml - Flutter dependencies

To run the notebook locally

Install requirements: pip install -r requirements.txt
Open summative/linear_regression/multivariate.ipynb
Run all cells
The notebook will combine the 5 Excel files, train the models, generate the visualizations, and save the best performing one.

To run the API locally

cd summative/API
pip install -r requirements.txt
uvicorn main:app --reload --host 0.0.0.0 --port 8000
Then open http://localhost:8000/docs

To run the Flutter app locally

cd summative/FlutterApp
flutter pub get
flutter run
Use Android Emulator (connects to localhost via 10.0.2.2:8000)

Models I built

Linear Regression
Random Forest
Decision Tree
The Random Forest performed best based on test MSE (lowest loss), so that's what gets saved as the final model.

Note

South Sudan is included in the data and you can see how its fragility scores compare to other countries. The model works for any country in the dataset.