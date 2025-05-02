import subprocess

def run_pipeline():
    try:
        subprocess.run(["python", "scripts/load_data.py"], check=True)
        print("Pipeline completed successfully")
    except subprocess.CalledProcessError as e:
        print(f"Pipeline failed: {e}")

if __name__ == "__main__":
    run_pipeline()