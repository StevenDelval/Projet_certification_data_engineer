```mermaid
erDiagram
    Meteo {
        date DATE PK
        int LAMBX PK,FK
        int LAMBY PK,FK
        float PRENEI_Q 
        float PRELIQ_Q
        float PE_Q
        float T_Q
        float TINF_H_Q
    }

    Mailles {
        int LAMBX PK
        int LAMBY PK
        float lat
        float lon
    }
```