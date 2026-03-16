"""
Hostname reputation checker for leaky-main.

Queries external security services for domain/hostname reputation data:
  - Sucuri SiteCheck (JSON API)
  - OTX AlienVault (JSON API)
  - Quttera (HTML scraping attempt + fallback link)
  - AbuseIPDB (external link only)
"""

import logging
import re
import requests
from bs4 import BeautifulSoup

from Utils.randomuser import GetUser

logger = logging.getLogger(__name__)

_REQUEST_TIMEOUT = 25
_USER_AGENT = str(GetUser()) #"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36"


def _safe_get(url: str, headers: dict | None = None, timeout: int = _REQUEST_TIMEOUT) -> requests.Response | None:
    """Perform a GET request, returning None on failure."""
    if headers is None:
        headers = {"User-Agent": _USER_AGENT}
    try:
        resp = requests.get(url, headers=headers, timeout=timeout)
        resp.raise_for_status()
        return resp
    except requests.exceptions.RequestException as exc:
        logger.warning("Request to %s failed: %s", url, exc)
        return None


# ---------------------------------------------------------------------------
# Sucuri SiteCheck
# ---------------------------------------------------------------------------

def check_sucuri(hostname: str) -> dict:
    """
    Query Sucuri SiteCheck API for the hostname.
    Returns a dict with scan results or error info.
    """
    result = {
        "service": "Sucuri SiteCheck",
        "hostname": hostname,
        "url": f"https://sitecheck.sucuri.net/results/{hostname}",
        "status": "error",
        "data": {},
    }

    api_url = f"https://sitecheck.sucuri.net/api/v3/?scan={hostname}"
    resp = _safe_get(api_url)
    if resp is None:
        result["data"]["error"] = "No se pudo conectar con Sucuri SiteCheck."
        return result

    try:
        data = resp.json()
    except Exception:
        result["data"]["error"] = "Respuesta no válida de Sucuri."
        return result

    result["status"] = "ok"

    # Extract relevant info from scan
    scan = data.get("scan", {}) or {}
    warnings = data.get("warnings", {}) or {}
    blacklists = data.get("blacklists", {}) or {}
    info_section = data.get("info", {}) or {}
    recommendations = data.get("recommendations", {}) or {}

    # Site info
    site_info = {}
    if isinstance(info_section, dict):
        for key in ["ip", "hostname", "cms", "web_server", "server_ip"]:
            if key in info_section:
                val = info_section[key]
                if isinstance(val, list):
                    site_info[key] = ", ".join(str(v) for v in val)
                else:
                    site_info[key] = str(val)

    # Flatten scan details
    scan_details = {}
    if isinstance(scan, dict):
        for key, val in scan.items():
            if isinstance(val, (str, int, float, bool)):
                scan_details[key] = val
            elif isinstance(val, list) and val:
                scan_details[key] = val

    # Blacklist status
    blacklist_info = {}
    is_blacklisted = False
    if isinstance(blacklists, dict):
        for bl_name, bl_data in blacklists.items():
            if isinstance(bl_data, dict):
                status = bl_data.get("status", "unknown")
                blacklist_info[bl_name] = status
                if status and str(status).lower() not in ("clean", "ok", "0", "false", ""):
                    is_blacklisted = True
            elif isinstance(bl_data, (str, int)):
                blacklist_info[bl_name] = str(bl_data)

    # Warning messages
    warning_list = []
    if isinstance(warnings, dict):
        for w_type, w_items in warnings.items():
            if isinstance(w_items, list):
                for item in w_items:
                    if isinstance(item, dict):
                        msg = item.get("msg") or item.get("details") or item.get("title") or str(item)
                        warning_list.append({"type": w_type, "message": str(msg)})
                    elif isinstance(item, str):
                        warning_list.append({"type": w_type, "message": item})
            elif isinstance(w_items, str):
                warning_list.append({"type": w_type, "message": w_items})

    # Recommendation messages
    rec_list = []
    if isinstance(recommendations, dict):
        for r_type, r_items in recommendations.items():
            if isinstance(r_items, list):
                for item in r_items:
                    if isinstance(item, dict):
                        msg = item.get("msg") or item.get("details") or item.get("title") or str(item)
                        rec_list.append({"type": r_type, "message": str(msg)})
                    elif isinstance(item, str):
                        rec_list.append({"type": r_type, "message": item})

    result["data"] = {
        "site_info": site_info,
        "scan": scan_details,
        "blacklisted": is_blacklisted,
        "blacklists": blacklist_info,
        "warnings": warning_list,
        "recommendations": rec_list,
        "risk_level": "Alto" if is_blacklisted else ("Medio" if warning_list else "Bajo"),
    }
    return result


# ---------------------------------------------------------------------------
# OTX AlienVault
# ---------------------------------------------------------------------------

def check_otx(hostname: str) -> dict:
    """
    Query OTX AlienVault public API for the hostname.
    Returns structured pulse/reputation info.
    """
    result = {
        "service": "OTX AlienVault",
        "hostname": hostname,
        "url": f"https://otx.alienvault.com/indicator/domain/{hostname}",
        "status": "error",
        "data": {},
    }

    api_url = f"https://otx.alienvault.com/api/v1/indicators/domain/{hostname}/general"
    resp = _safe_get(api_url)
    if resp is None:
        result["data"]["error"] = "No se pudo conectar con OTX AlienVault."
        return result

    try:
        data = resp.json()
    except Exception:
        result["data"]["error"] = "Respuesta no válida de OTX."
        return result

    result["status"] = "ok"

    # Extract key fields
    pulse_info = data.get("pulse_info", {}) or {}
    pulse_count = pulse_info.get("count", 0)

    # Pulses (threat intelligence indicators)
    pulses = []
    for p in (pulse_info.get("pulses") or [])[:15]:  # limit to 15
        pulses.append({
            "name": p.get("name", ""),
            "description": (p.get("description") or "")[:200],
            "created": p.get("created", ""),
            "tags": (p.get("tags") or [])[:10],
            "adversary": p.get("adversary") or "",
            "targeted_countries": p.get("targeted_countries") or [],
        })

    # Whois, country, etc.
    whois_url = data.get("whois", "")
    country = ""
    city = ""
    asn = ""

    # Sometimes the data has a different shape
    indicator = data.get("indicator", hostname)
    sections = data.get("sections") or []

    # Reputation & validation
    validation = data.get("validation") or []
    val_messages = []
    if isinstance(validation, list):
        for v in validation:
            if isinstance(v, dict):
                val_messages.append(v.get("message", str(v)))
            elif isinstance(v, str):
                val_messages.append(v)

    # Alexa ranking (if present)
    alexa = data.get("alexa") or ""

    result["data"] = {
        "indicator": indicator,
        "pulse_count": pulse_count,
        "pulses": pulses,
        "whois": whois_url,
        "country": country,
        "alexa": alexa,
        "validation": val_messages,
        "sections": sections,
        "risk_level": "Alto" if pulse_count > 5 else ("Medio" if pulse_count > 0 else "Bajo"),
    }
    return result


# ---------------------------------------------------------------------------
# Quttera
# ---------------------------------------------------------------------------

def check_quttera(hostname: str) -> dict:
    """
    Attempt to scrape Quttera scan results for the hostname.
    Falls back to providing a link if scraping fails (JS-rendered page).
    """
    result = {
        "service": "Quttera",
        "hostname": hostname,
        "url": f"https://quttera.com/detailed_report/{hostname}",
        "status": "link_only",
        "data": {},
    }

    # Try fetching the results page
    resp = _safe_get(
        f"https://quttera.com/detailed_report/{hostname}",
        headers={
            "User-Agent": _USER_AGENT,
            "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
            "Accept-Language": "en-US,en;q=0.5",
        },
        timeout=20,
    )

    if resp is None:
        result["data"]["message"] = "No se pudo conectar con Quttera. Usa el enlace directo."
        return result

    try:
        soup = BeautifulSoup(resp.text, "html.parser")

        # Try to extract scan status / summary data from the HTML
        extracted_data = {}

        # Look for scan status elements
        status_elements = soup.select(".scan-status, .scan_status, .status-badge, .verdict")
        if status_elements:
            extracted_data["scan_status"] = status_elements[0].get_text(strip=True)

        # Look for verdict / malware status
        verdict_elements = soup.select(".verdict, .scan-result, .result-status, .threat-status")
        if verdict_elements:
            extracted_data["verdict"] = verdict_elements[0].get_text(strip=True)

        # Look for any data tables with scan info
        tables = soup.select("table")
        table_data = []
        for table in tables[:3]:  # max 3 tables
            rows = table.select("tr")
            for row in rows:
                cells = row.select("td, th")
                if len(cells) >= 2:
                    key = cells[0].get_text(strip=True)
                    val = cells[1].get_text(strip=True)
                    if key and val and len(key) < 100 and len(val) < 300:
                        table_data.append({"key": key, "value": val})

        if table_data:
            extracted_data["details"] = table_data

        # Look for threat/warning indicators in page text
        page_text = soup.get_text(" ", strip=True).lower()
        threat_keywords = ["malicious", "suspicious", "clean", "potentially suspicious",
                          "no threats", "malware detected", "phishing", "blacklisted"]
        found_indicators = [kw for kw in threat_keywords if kw in page_text]
        if found_indicators:
            extracted_data["indicators"] = found_indicators

        # Check for "scan in progress" or "not scanned" messages
        if "scan in progress" in page_text or "scanning" in page_text:
            extracted_data["scan_status"] = "Escaneo en progreso"
        elif "not found" in page_text or "no report" in page_text:
            extracted_data["scan_status"] = "Sin reporte disponible"

        if extracted_data:
            result["status"] = "partial"
            result["data"] = extracted_data
        else:
            result["data"]["message"] = "Los resultados de Quttera se renderizan con JavaScript. Usa el enlace directo para ver el reporte completo."

    except Exception as exc:
        logger.warning("Error parsing Quttera page: %s", exc)
        result["data"]["message"] = "Error al analizar la página de Quttera. Usa el enlace directo."

    return result


# ---------------------------------------------------------------------------
# AbuseIPDB
# ---------------------------------------------------------------------------

def check_abuseipdb(hostname: str) -> dict:
    """
    Returns a link to AbuseIPDB — no API scraping (as per requirements).
    """
    return {
        "service": "AbuseIPDB",
        "hostname": hostname,
        "url": f"https://www.abuseipdb.com/check/{hostname}",
        "status": "link_only",
        "data": {
            "message": "Haz clic en el enlace para ver el reporte completo en AbuseIPDB.",
        },
    }


def check_custom(hostname: str, feed: dict) -> dict:
    """Returns a link to a custom user-defined API feed."""
    feed_name = feed.get("name", "Custom Feed")
    feed_url = feed.get("url", "")
    
    if feed_url and not feed_url.endswith('/') and not feed_url.endswith('='):
        feed_url += '/'
        
    full_url = f"{feed_url}{hostname}"
    
    return {
        "service": feed_name,
        "hostname": hostname,
        "url": full_url,
        "status": "link_only",
        "data": {
            "message": f"Haz clic en el enlace para consultar {feed_name}.",
        },
    }


# ---------------------------------------------------------------------------
# Combined check
# ---------------------------------------------------------------------------

def check_all(hostname: str, custom_feeds: list[dict] = None) -> list[dict]:
    """Run all hostname reputation checks and return a list of results."""
    hostname = hostname.strip().lower()
    # Remove protocol if present
    hostname = re.sub(r'^https?://', '', hostname)
    hostname = hostname.rstrip('/')

    results = []
    results.append(check_sucuri(hostname))
    results.append(check_otx(hostname))
    results.append(check_quttera(hostname))
    results.append(check_abuseipdb(hostname))
    
    if custom_feeds:
        for feed in custom_feeds:
            results.append(check_custom(hostname, feed))
            
    return results
