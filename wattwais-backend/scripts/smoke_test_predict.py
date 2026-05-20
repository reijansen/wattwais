import json
import os
import sys
import urllib.request


def main() -> int:
    base_url = os.getenv("PREDICT_API_BASE_URL", "http://127.0.0.1:8000").rstrip("/")
    url = f"{base_url}/predict"

    payload = {
        "appliances": [
            {
                "name": "Aircon",
                "quantity": 1,
                "watts": 900,
                "hours_per_day": 6,
                "days_per_week": 7,
            },
            {
                "name": "Refrigerator",
                "quantity": 1,
                "watts": 150,
                "hours_per_day": 24,
                "days_per_week": 7,
            },
        ],
        "base_rate": 12.5,
        "six_month_total_bill": 18000,
        "six_month_total_kwh": 1500,
        "monthly_budget": 3500,
    }

    data = json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(
        url,
        data=data,
        headers={"Content-Type": "application/json"},
        method="POST",
    )

    try:
        with urllib.request.urlopen(req, timeout=20) as resp:
            body = resp.read().decode("utf-8")
            if resp.status != 200:
                print(f"FAIL: status={resp.status} body={body}")
                return 1
            parsed = json.loads(body)
    except Exception as e:
        print(f"FAIL: request error: {e}")
        return 1

    if "estimated_bill" not in parsed:
        print(f"FAIL: missing estimated_bill in response: {parsed}")
        return 1

    print("OK:", {"estimated_bill": parsed.get("estimated_bill"), "estimated_monthly_kwh": parsed.get("estimated_monthly_kwh")})
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

