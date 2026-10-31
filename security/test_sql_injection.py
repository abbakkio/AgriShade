"""
Cybersecurity Demonstration: SQL Injection Vulnerability vs Parameterized Defense
ICT Assignment 3: Database Systems and Cybersecurity
Author: Azat Madiyev (AITU)
"""

import sqlite3
from sqlalchemy import text
from backend.database import engine, Base
from backend.models import DiagnosticScan


def print_header(title: str):
    print("\n" + "=" * 90)
    print(f" {title}")
    print("=" * 90)


def demonstrate_sql_injection_defense():
    """
    Demonstrates Task 4 requirement:
    1. Unsafe query with naive string concatenation.
    2. Safe query using Parameterized Prepared Statements / ORM parameter binding.
    """
    # Malicious injection payload supplied by an attacker
    malicious_input = "' OR '1'='1"

    print_header("CYBERSECURITY EXPERIMENT: SQL INJECTION VULNERABILITY ANALYSIS")
    print(f"[*] Attacker Injected Input Payload: {malicious_input}")
    print("[*] Target Table: scans (In-Field Diagnostic Pathology Records)")

    # -------------------------------------------------------------------------
    # 1. THE VULNERABLE APPROACH: STRING CONCATENATION
    # -------------------------------------------------------------------------
    print_header("1. VULNERABLE CODE (String Concatenation)")
    unsafe_sql = f"SELECT id, crop_type, disease_label, severity_level FROM scans WHERE disease_label = '{malicious_input}'"
    print(f"Code Pattern:  query = \"SELECT ... WHERE disease_label = '\" + user_input + \"'\"")
    print(f"Resulting SQL: {unsafe_sql}")
    print("\nExecuting Vulnerable Query Against Database...")

    with engine.connect() as conn:
        try:
            unsafe_results = conn.execute(text(unsafe_sql)).fetchall()
            print(f"[!] EXPLOIT SUCCEEDED! Returned {len(unsafe_results)} confidential scan records:")
            for r in unsafe_results[:5]:
                print(f"    - ID: {r[0]:<2} | Crop: {r[1]:<8} | Severity: {r[3]:<8} | Disease: {r[2]}")
            if len(unsafe_results) > 5:
                print(f"    ... and {len(unsafe_results) - 5} more records leaked!")
            print("\n[CRITICAL VULNERABILITY EXPLANATION]:")
            print("Because user input was concatenated directly into the SQL string, the single-quote (`)")
            print("broke out of the data literal, and the logical condition `OR '1'='1` evaluated to TRUE")
            print("for every single row in the database, causing complete unauthorized data breach.")
        except Exception as e:
            print(f"[!] Execution failed: {e}")

    # -------------------------------------------------------------------------
    # 2. THE DEFENDED APPROACH: PARAMETERIZED PREPARED STATEMENT
    # -------------------------------------------------------------------------
    print_header("2. DEFENDED CODE (Parameterized Query / Prepared Statement)")
    safe_sql = "SELECT id, crop_type, disease_label, severity_level FROM scans WHERE disease_label = :disease_param"
    print(f"Code Pattern:  cursor.execute(\"SELECT ... WHERE disease_label = :param\", {{'param': user_input}})")
    print(f"Parameterized: {safe_sql}  [Bound Parameter: disease_param = \"{malicious_input}\"]")
    print("\nExecuting Defended Parameterized Query Against Database...")

    with engine.connect() as conn:
        safe_stmt = text(safe_sql)
        safe_results = conn.execute(safe_stmt, {"disease_param": malicious_input}).fetchall()
        print(f"[✓] DEFENSE VERIFIED! Returned {len(safe_results)} rows.")
        print("\n[CYBERSECURITY MITIGATION EXPLANATION]:")
        print("In the parameterized prepared statement, the database engine compiles the SQL query structure")
        print("BEFORE binding the user input. The input payload is treated strictly as an immutable string literal,")
        print("searching for a disease whose literal name is `' OR '1'='1`.")
        print("The injected quotes and logical operators cannot alter the query execution plan.")

    print_header("SUMMARY TABLE FOR ASSIGNMENT 3 REPORT & PRESENTATION")
    print("| Metric                     | Unsafe Raw Concatenation       | Safe Parameterized Statement   |")
    print("|----------------------------|--------------------------------|--------------------------------|")
    print(f"| Input Payload              | {malicious_input:<30} | {malicious_input:<30} |")
    print("| Injected SQL Interpreted?  | YES (Critical Vulnerability)   | NO (Treated as Literal Data)   |")
    print(f"| Rows Leaked / Exposed      | {len(unsafe_results):<30} | {len(safe_results):<30} |")
    print("| Defense Mechanism          | None                           | AST Pre-Compilation & Binding  |")
    print("=" * 90 + "\n")


if __name__ == "__main__":
    demonstrate_sql_injection_defense()
