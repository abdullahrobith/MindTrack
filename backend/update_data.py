from scripts.update_articles import main as update_articles
from scripts.update_trends import main as update_trends

if __name__ == "__main__":
    print("Update Articles...")
    update_articles()

    print("Update Trends...")
    update_trends()

    print("Selesai")