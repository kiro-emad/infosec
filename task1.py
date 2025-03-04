import itertools
import string
import os

# Hardcoded correct password
CORRECT_PASSWORD = "kok"

def dictionary_attack():
    try:
        dict_path = r"D:\infosec\rockyou.txt"

        if not os.path.exists(dict_path):
            print(f"❌ Error: Dictionary file not found at {dict_path}")
            return None  # نعيد None بدلاً من False لتحديد ما إذا وجدنا كلمة المرور

        print(f"📂 Trying to open dictionary file: {dict_path}")
        
        with open(dict_path, "r", encoding="latin-1") as file:
            for line in file:
                word = line.strip()
                if word == CORRECT_PASSWORD:
                    print(f"✅ Dictionary Attack Successful! Password found: {word}")
                    return word  # نعيد كلمة المرور عند النجاح
        
        print("❌ Dictionary Attack Failed: Password not found in dictionary.")
    except Exception as e:
        print("⚠️ Failed to load dictionary:", e)

    return None


def brute_force_attack():
    chars = string.ascii_letters  # a-z, A-Z
    attempt_count = 0  

    print("🚀 Starting Brute Force Attack... This may take some time.")

    for attempt in itertools.product(chars, repeat=5):  
        guess = "".join(attempt)
        attempt_count += 1

        if guess == CORRECT_PASSWORD:
            print(f"🔥 Brute Force Successful in {attempt_count} attempts! Password found: {guess}")
            return guess  # عند النجاح، نطبع كلمة المرور التي وجدناها
        
        if attempt_count % 100000 == 0:
            print(f"⏳ Attempts: {attempt_count}... Still trying.")

    return None

def main():
    username = input("👤 Enter username: ")

    print("\n🔍 Attempting Dictionary Attack...")
    found_password = dictionary_attack()

    if found_password:
        print(f"✅ Login Successful (Dictionary Attack) - Password: {found_password}")
    else:
        print("\n💥 Dictionary Attack failed. Attempting Brute Force Attack...")
        found_password = brute_force_attack()
        if found_password:
            print(f"✅ Login Successful (Brute Force Attack) - Password: {found_password}")
        else:
            print("❌ Login Failed!")

if __name__ == "__main__":
    main()
