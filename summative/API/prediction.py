import joblib
import pandas as pd
import numpy as np
from sklearn.preprocessing import StandardScaler
from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import mean_squared_error
import os

# Get the directory where this file is located
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
MODEL_PATH = os.path.join(BASE_DIR, '..', 'linear_regression', 'best_fragility_model.pkl')

def load_model():
    """Load the saved model and preprocessing artifacts"""
    try:
        if not os.path.exists(MODEL_PATH):
            raise FileNotFoundError(f"Model file not found at {MODEL_PATH}")
        artifacts = joblib.load(MODEL_PATH)
        return artifacts
    except Exception as e:
        raise Exception(f"Failed to load model: {str(e)}")

def predict_fragility(input_data: dict):
    """
    Make prediction using loaded model
    
    Args:
        input_data: Dictionary with 12 indicator values
        
    Returns:
        dict: prediction result with score and risk level
    """
    try:
        artifacts = load_model()
        model = artifacts['model']
        scaler = artifacts['scaler']
        features = artifacts['features']
        
        # Prepare input - ensure correct column order
        input_df = pd.DataFrame([input_data])
        input_df = input_df[features]
        input_scaled = scaler.transform(input_df)
        
        # Predict
        score = float(model.predict(input_scaled)[0])
        
        # Determine risk level
        if score < 40:
            risk = "Sustainable"
        elif score < 60:
            risk = "Stable"
        elif score < 80:
            risk = "Warning"
        elif score < 100:
            risk = "Alert"
        else:
            risk = "Critical"
        
        return {
            "fragility_score": round(score, 2),
            "risk_level": risk,
            "model_used": artifacts.get('model_type', 'Unknown')
        }
    except Exception as e:
        raise Exception(f"Prediction failed: {str(e)}")

def retrain_model(new_data: list):
    """
    Retrain model with new data
    
    Args:
        new_data: List of dictionaries with features and target
        
    Returns:
        dict: Training metrics
    """
    try:
        # Convert to DataFrame
        df = pd.DataFrame(new_data)
        
        # Required features
        features = ['C1: Security Apparatus', 'C2: Factionalized Elites', 'C3: Group Grievance',
                    'E1: Economy', 'E2: Economic Inequality', 'E3: Human Flight and Brain Drain',
                    'P1: State Legitimacy', 'P2: Public Services', 'P3: Human Rights',
                    'S1: Demographic Pressures', 'S2: Refugees and IDPs', 'X1: External Intervention']
        
        # Check if required columns exist
        if 'Total' not in df.columns:
            raise ValueError("Input data must contain 'Total' column as target")
        
        missing_features = [f for f in features if f not in df.columns]
        if missing_features:
            raise ValueError(f"Missing features: {missing_features}")
        
        X = df[features]
        y = df['Total']
        
        # Standardize
        scaler = StandardScaler()
        X_scaled = scaler.fit_transform(X)
        
        # Train Random Forest (best model)
        model = RandomForestRegressor(n_estimators=150, max_depth=15, random_state=42)
        model.fit(X_scaled, y)
        
        # Calculate metrics
        predictions = model.predict(X_scaled)
        mse = mean_squared_error(y, predictions)
        
        # Save new model
        artifacts = {
            'model': model,
            'scaler': scaler,
            'features': features,
            'model_type': 'Random Forest (Retrained)',
            'performance_metrics': {'mse': mse}
        }
        joblib.dump(artifacts, MODEL_PATH)
        
        return {
            "message": "Model retrained successfully",
            "mse": float(mse),
            "samples_used": len(df)
        }
    except Exception as e:
        raise Exception(f"Retraining failed: {str(e)}")