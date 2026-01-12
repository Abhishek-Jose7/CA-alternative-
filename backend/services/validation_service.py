
import re

class ValidationService:
    @staticmethod
    def validate_gstin(gstin: str) -> bool:
        """
        Validates the format of an Indian GSTIN.
        Format: 2 digits (state code), 10 chars (PAN), 1 digit (entity number), 1 char (Z), 1 digit/char (checksum).
        """
        if not gstin or gstin == "Not Found":
            return False
        
        pattern = r"^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$"
        return bool(re.match(pattern, gstin))

    @staticmethod
    def validate_invoice_math(invoice_data: dict) -> dict:
        """
        Performs rule-based mathematical validation on extracted invoice data.
        """
        checks = {
            "math_valid": True,
            "errors": [],
            "warnings": []
        }

        try:
            details = invoice_data.get("invoiceDetails", {})
            line_items = invoice_data.get("lineItems", [])
            summary = invoice_data.get("summary", {})

            # 1. Check if Sum(line_items) == GrandTotal
            calc_total = sum(float(item.get("amount", 0)) for item in line_items)
            grand_total = float(summary.get("grandTotal", 0) or details.get("totalAmount", 0))

            if abs(calc_total - grand_total) > 1.0: # Allow for small rounding
                checks["math_valid"] = False
                checks["warnings"].append(f"Math Mismatch: Line items sum up to ₹{calc_total}, but grand total is ₹{grand_total}.")

            # 2. Check Tax Calculations
            tax_analysis = invoice_data.get("taxAnalysis", [])
            calc_tax = 0
            for t in tax_analysis:
                calc_tax += float(t.get("cgst", 0)) + float(t.get("sgst", 0)) + float(t.get("igst", 0))
            
            total_tax = float(summary.get("totalTax", 0))
            if abs(calc_tax - total_tax) > 1.0:
                 checks["warnings"].append(f"Tax Mismatch: Calculated taxes ({calc_tax}) do not match summary tax ({total_tax}).")

        except Exception as e:
            checks["errors"].append(f"Validation Error: {str(e)}")
            checks["math_valid"] = False

        return checks

    @staticmethod
    def check_hitl_criteria(data: dict, doc_type: str) -> bool:
        """
        Determines if a document needs human intervention (CA Review).
        """
        if doc_type == "notice":
            risk = str(data.get("riskLevel", "")).lower()
            penalty = str(data.get("penalty", "0")).replace("₹", "").replace(",", "").strip()
            
            try:
                penalty_val = float(penalty) if penalty.replace('.','',1).isdigit() else 0
            except:
                penalty_val = 0

            # Rule: High Risk OR Penalty > 50,000 needs review
            if risk == "high" or penalty_val > 50000:
                return True
        
        if doc_type == "invoice":
            # Rule: Large invoices (> 5 Lakhs) or math errors
            grand_total = float(data.get("summary", {}).get("grandTotal", 0))
            if grand_total > 500000:
                return True

        return False

validation_service = ValidationService()
