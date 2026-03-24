from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from typing import List
from prediction import predict_fragility, retrain_model
import uvicorn

app = FastAPI(
    title="State Fragility Prediction API",
    description="API for predicting state fragility scores using machine learning models. Supports 176 countries with data from 2019-2023.",
    version="1.0.0"
)

# Configure CORS - Includes Android emulator and production URLs
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:3000",      # React/Vue development
        "http://localhost:8080",      # Flutter web development
        "http://localhost:5000",      # Common Flutter port
        "http://127.0.0.1:8000",      # Local testing
        "http://10.0.2.2:8000",       # Android emulator localhost
        "http://10.0.2.2:3000",       # Android emulator alternative
        "https://*.onrender.com",     # Render deployment
    ],
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    allow_headers=["Content-Type", "Authorization", "Accept", "Origin", "X-Requested-With"],
    max_age=3600,
)

# Pydantic model with validation for prediction input
class FragilityInput(BaseModel):
    c1_security_apparatus: float = Field(..., ge=0, le=10, description="Security Apparatus (0-10)")
    c2_factionalized_elites: float = Field(..., ge=0, le=10, description="Factionalized Elites (0-10)")
    c3_group_grievance: float = Field(..., ge=0, le=10, description="Group Grievance (0-10)")
    e1_economy: float = Field(..., ge=0, le=10, description="Economy (0-10)")
    e2_economic_inequality: float = Field(..., ge=0, le=10, description="Economic Inequality (0-10)")
    e3_human_flight: float = Field(..., ge=0, le=10, description="Human Flight and Brain Drain (0-10)")
    p1_state_legitimacy: float = Field(..., ge=0, le=10, description="State Legitimacy (0-10)")
    p2_public_services: float = Field(..., ge=0, le=10, description="Public Services (0-10)")
    p3_human_rights: float = Field(..., ge=0, le=10, description="Human Rights (0-10)")
    s1_demographic_pressures: float = Field(..., ge=0, le=10, description="Demographic Pressures (0-10)")
    s2_refugees_idps: float = Field(..., ge=0, le=10, description="Refugees and IDPs (0-10)")
    x1_external_intervention: float = Field(..., ge=0, le=10, description="External Intervention (0-10)")
    
    class Config:
        json_schema_extra = {
            "example": {
                "c1_security_apparatus": 9.5,
                "c2_factionalized_elites": 8.8,
                "c3_group_grievance": 8.2,
                "e1_economy": 8.0,
                "e2_economic_inequality": 7.5,
                "e3_human_flight": 7.0,
                "p1_state_legitimacy": 9.0,
                "p2_public_services": 6.5,
                "p3_human_rights": 6.0,
                "s1_demographic_pressures": 8.5,
                "s2_refugees_idps": 9.0,
                "x1_external_intervention": 8.0
            }
        }

class RetrainInput(BaseModel):
    data: List[dict]

@app.get("/")
def read_root():
    return {
        "message": "State Fragility Prediction API",
        "docs": "/docs",
        "endpoints": {
            "predict": "/predict (POST)",
            "retrain": "/retrain (POST)",
            "health": "/health (GET)"
        }
    }

@app.post("/predict")
def predict(input_data: FragilityInput):
    """
    Predict state fragility score based on 12 indicators.
    Returns fragility score (0-120) and risk classification.
    """
    try:
        # Convert to dict with original column names (matching the training data)
        data = {
            'C1: Security Apparatus': input_data.c1_security_apparatus,
            'C2: Factionalized Elites': input_data.c2_factionalized_elites,
            'C3: Group Grievance': input_data.c3_group_grievance,
            'E1: Economy': input_data.e1_economy,
            'E2: Economic Inequality': input_data.e2_economic_inequality,
            'E3: Human Flight and Brain Drain': input_data.e3_human_flight,
            'P1: State Legitimacy': input_data.p1_state_legitimacy,
            'P2: Public Services': input_data.p2_public_services,
            'P3: Human Rights': input_data.p3_human_rights,
            'S1: Demographic Pressures': input_data.s1_demographic_pressures,
            'S2: Refugees and IDPs': input_data.s2_refugees_idps,
            'X1: External Intervention': input_data.x1_external_intervention
        }
        
        result = predict_fragility(data)
        return result
    
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/retrain")
def retrain(input_data: RetrainInput):
    """
    Retrain the model with new data.
    Expects list of records with all 12 features and 'Total' target.
    """
    try:
        result = retrain_model(input_data.data)
        return result
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/health")
def health_check():
    """Health check endpoint"""
    try:
        # Try to load model to verify it's working
        from prediction import load_model
        load_model()
        return {"status": "healthy", "model": "loaded"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Model not loaded: {str(e)}")

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)