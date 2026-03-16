"""
Leak search API module for leaky-main web app.
Adapted from Project_custom/Utils/leak_search.py — stripped of CLI/colorama dependencies.

Sources:
  - Hudson Rock Cavalier API (email, domain, username)
  - ProxyNova COMB (email only)
  - LeakCheck public API (email only)
"""

import json
import logging
import time
from dataclasses import asdict, dataclass, field
from datetime import datetime
from urllib.parse import quote, unquote

import requests

from Utils.randomuser import GetUser

logger = logging.getLogger(__name__)

_REQUEST_TIMEOUT: int = 20
_MAX_RETRIES: int = 3
_RETRY_BASE_DELAY: float = 3.0
_HTTP_ERROR_KEY: str = "__http_error__"
_HUDSON_INVALID_EMAIL_ERROR: str = "Email must be a valid email address"

# Hudson Rock Cavalier API base URL.
_HR_BASE = "https://cavalier.hudsonrock.com/api/json/v2/osint-tools"

# ProxyNova COMB (Collection Of Many Breaches) — email-only, no key needed.
_PN_BASE = "https://api.proxynova.com/comb"

# LeakCheck public API base (email-only).
_LC_BASE = "https://leakcheck.net/api/public"


# ---------------------------------------------------------------------------
# Data classes
# ---------------------------------------------------------------------------

@dataclass
class StealerEntry:
    """One stealer-log record returned by Hudson Rock."""
    date_compromised: str = ""
    stealer_family: str = ""
    computer_name: str = ""
    operating_system: str = ""
    ip: str = ""
    malware_path: str = ""
    antiviruses: list[str] = field(default_factory=list)
    top_logins: list[str] = field(default_factory=list)
    top_passwords: list[str] = field(default_factory=list)
    total_corporate_services: int = 0
    total_user_services: int = 0


@dataclass
class CombEntry:
    """One credential line from the ProxyNova COMB dataset."""
    line: str = ""
    email: str = ""
    password: str = ""


@dataclass
class LcSource:
    """One breach/source entry returned by the LC endpoint."""
    name: str = ""
    date: str = ""


@dataclass
class LeakReport:
    """Aggregated results from all sources for a single target."""
    target: str = ""
    target_type: str = ""  # "email" | "domain" | "username"
    # Hudson Rock
    hr_message: str = ""
    hr_stealers: list[StealerEntry] = field(default_factory=list)
    hr_employees: list[dict] = field(default_factory=list)
    hr_users: list[dict] = field(default_factory=list)
    # ProxyNova COMB (email only)
    comb_count: int = 0
    comb_entries: list[CombEntry] = field(default_factory=list)
    # LC_BASE (email only)
    lc_success: bool = False
    lc_found: int = 0
    lc_fields: list[str] = field(default_factory=list)
    lc_sources: list[LcSource] = field(default_factory=list)


# ---------------------------------------------------------------------------
# Target-type detection
# ---------------------------------------------------------------------------

def _detect_type(target: str) -> str:
    if "@" in target:
        return "email"
    if "." in target and " " not in target:
        return "domain"
    return "username"


def _normalize_target(target: str) -> str:
    target = target.strip()
    if "%" in target:
        target = unquote(target)
    return target.strip()


# ---------------------------------------------------------------------------
# HTTP helpers
# ---------------------------------------------------------------------------

def _get(url: str, params: dict | None = None) -> dict | None:
    headers = {"User-Agent": str(GetUser())}
    for attempt in range(1, _MAX_RETRIES + 1):
        try:
            resp = requests.get(url, params=params, headers=headers, timeout=_REQUEST_TIMEOUT)
            resp.raise_for_status()
            return resp.json()
        except requests.exceptions.Timeout:
            delay = _RETRY_BASE_DELAY * (2 ** (attempt - 1))
            logger.warning("Request timed out (attempt %d/%d). Retrying in %.0fs...", attempt, _MAX_RETRIES, delay)
            time.sleep(delay)
        except requests.exceptions.HTTPError as exc:
            if exc.response is not None and exc.response.status_code == 404:
                return {}
            status = exc.response.status_code if exc.response is not None else 0
            body = ""
            if exc.response is not None:
                try:
                    body = (exc.response.text or "").strip()
                except Exception:
                    body = ""
            if body and len(body) > 300:
                body = body[:300] + "..."
            logger.error("HTTP error (%s): %s", status, exc)
            return {
                _HTTP_ERROR_KEY: status,
                "__url__": getattr(exc.response, "url", url),
                "__body__": body,
            }
        except requests.exceptions.RequestException as exc:
            logger.error("Request failed: %s", exc)
            return None
    logger.error("All %d attempts failed for %s.", _MAX_RETRIES, url)
    return None


def _is_http_error(data: object) -> bool:
    return isinstance(data, dict) and _HTTP_ERROR_KEY in data


def _extract_error_from_body(body: str) -> str:
    body = (body or "").strip()
    if not body:
        return ""
    try:
        parsed = json.loads(body)
    except Exception:
        return body
    if isinstance(parsed, dict):
        err = parsed.get("error")
        if isinstance(err, str) and err.strip():
            return err.strip()
    return body


# ---------------------------------------------------------------------------
# Hudson Rock
# ---------------------------------------------------------------------------

def _parse_stealer(raw: dict) -> StealerEntry:
    return StealerEntry(
        date_compromised=raw.get("date_compromised", ""),
        stealer_family=raw.get("stealer_family", "Unknown"),
        computer_name=raw.get("computer_name", ""),
        operating_system=raw.get("operating_system", ""),
        ip=raw.get("ip", ""),
        malware_path=raw.get("malware_path", ""),
        antiviruses=raw.get("antiviruses") or [],
        top_logins=raw.get("top_logins") or [],
        top_passwords=raw.get("top_passwords") or [],
        total_corporate_services=int(raw.get("total_corporate_services") or 0),
        total_user_services=int(raw.get("total_user_services") or 0),
    )


def _fetch_hudson_rock(target: str, target_type: str) -> tuple[str, list[StealerEntry], list[dict], list[dict]]:
    endpoint_map = {
        "email": f"{_HR_BASE}/search-by-email",
        "domain": f"{_HR_BASE}/search-by-domain",
        "username": f"{_HR_BASE}/search-by-username",
    }
    param_map = {"email": "email", "domain": "domain", "username": "username"}

    url = endpoint_map[target_type]
    param_key = param_map[target_type]
    target = _normalize_target(target)

    if target_type == "email":
        safe_email = quote(target, safe="@+._-")
        data = _get(f"{url}?{param_key}={safe_email}")
    else:
        data = _get(url, params={param_key: target})

    if data is None:
        return "", [], [], []
    if _is_http_error(data):
        status = int(data.get(_HTTP_ERROR_KEY) or 0)
        if target_type == "email" and status == 400 and "@" in target:
            err = _extract_error_from_body(str(data.get("__body__") or ""))
            return err or _HUDSON_INVALID_EMAIL_ERROR, [], [], []
        return "", [], [], []
    if not data:
        return "", [], [], []

    message: str = data.get("message", "")
    raw_stealers: list[dict] = data.get("stealers", []) or []
    stealers = [_parse_stealer(s) for s in raw_stealers]

    employees: list[dict] = []
    users: list[dict] = []

    data_block = data.get("data")
    if isinstance(data_block, dict):
        all_urls = data_block.get("all_urls") or []
        if isinstance(all_urls, list) and all_urls:
            for item in all_urls:
                try:
                    t = (item.get("type") or "").lower()
                    rec = {
                        "url": item.get("url", "") or "",
                        "occurrence": int(item.get("occurrence") or 0),
                    }
                except Exception:
                    continue
                if t == "employee":
                    employees.append(rec)
                elif t == "user":
                    users.append(rec)
            return message, stealers, employees, users

        emp_urls = data_block.get("employees_urls") or []
        if isinstance(emp_urls, list):
            for item in emp_urls:
                if not isinstance(item, dict):
                    continue
                employees.append({
                    "url": item.get("url", "") or "",
                    "occurrence": int(item.get("occurrence") or 0),
                })
        client_urls = data_block.get("clients_urls") or []
        if isinstance(client_urls, list):
            for item in client_urls:
                if not isinstance(item, dict):
                    continue
                users.append({
                    "url": item.get("url", "") or "",
                    "occurrence": int(item.get("occurrence") or 0),
                })

    stats = data.get("stats")
    if (not employees and not users) and isinstance(stats, dict):
        emp_stats_urls = stats.get("employees_urls") or []
        if isinstance(emp_stats_urls, list):
            for u in emp_stats_urls:
                if isinstance(u, str):
                    employees.append({"url": u, "occurrence": None})
        client_stats_urls = stats.get("clients_urls") or []
        if isinstance(client_stats_urls, list):
            for u in client_stats_urls:
                if isinstance(u, str):
                    users.append({"url": u, "occurrence": None})

    raw_employees = data.get("employees")
    raw_users = data.get("users")
    if isinstance(raw_employees, list) and not employees:
        for item in raw_employees:
            if isinstance(item, dict):
                employees.append({
                    "url": item.get("url", "") or "",
                    "occurrence": int(item.get("occurrence") or 0),
                })
    if isinstance(raw_users, list) and not users:
        for item in raw_users:
            if isinstance(item, dict):
                users.append({
                    "url": item.get("url", "") or "",
                    "occurrence": int(item.get("occurrence") or 0),
                })

    return message, stealers, employees or [], users or []


# ---------------------------------------------------------------------------
# ProxyNova COMB
# ---------------------------------------------------------------------------

def _fetch_comb(email: str) -> tuple[int, list[CombEntry]]:
    data = _get(_PN_BASE, params={"query": email})
    if not data or _is_http_error(data):
        return 0, []

    count: int = int(data.get("count") or 0)
    lines: list[str] = data.get("lines") or []

    entries: list[CombEntry] = []
    for line in lines:
        line = line.strip()
        if not line:
            continue
        if ":" in line:
            _, _, password = line.partition(":")
        else:
            password = ""
        entries.append(CombEntry(line=line, email=email, password=password))

    return count, entries


# ---------------------------------------------------------------------------
# LeakCheck
# ---------------------------------------------------------------------------

def _fetch_lc(email: str) -> tuple[bool, int, list[str], list[LcSource]]:
    if not _LC_BASE:
        return False, 0, [], []

    data = _get(_LC_BASE, params={"check": email})
    if not data or _is_http_error(data):
        return False, 0, [], []

    success = bool(data.get("success") is True)
    found = int(data.get("found") or 0)

    fields_raw = data.get("fields") or []
    fields = [str(x) for x in fields_raw] if isinstance(fields_raw, list) else []

    sources: list[LcSource] = []
    sources_raw = data.get("sources") or []
    if isinstance(sources_raw, list):
        for item in sources_raw:
            if not isinstance(item, dict):
                continue
            sources.append(LcSource(
                name=str(item.get("name") or ""),
                date=str(item.get("date") or ""),
            ))

    return success, found, fields, sources


# ---------------------------------------------------------------------------
# High-level lookup (for web use)
# ---------------------------------------------------------------------------

def lookup_report(target: str) -> LeakReport:
    """
    Perform a full leak lookup for the given target.
    Returns a LeakReport with results from all applicable sources.
    """
    target = _normalize_target(target)
    target_type = _detect_type(target)

    report = LeakReport(target=target, target_type=target_type)

    # Hudson Rock
    hr_msg, hr_stealers, hr_employees, hr_users = _fetch_hudson_rock(target, target_type)
    report.hr_message = hr_msg
    report.hr_stealers = hr_stealers
    report.hr_employees = hr_employees or []
    report.hr_users = hr_users or []

    # Email-only sources
    if target_type == "email":
        if _HUDSON_INVALID_EMAIL_ERROR not in (report.hr_message or ""):
            comb_count, comb_entries = _fetch_comb(target)
            report.comb_count = comb_count
            report.comb_entries = comb_entries

            lc_success, lc_found, lc_fields, lc_sources = _fetch_lc(target)
            report.lc_success = lc_success
            report.lc_found = lc_found
            report.lc_fields = lc_fields
            report.lc_sources = lc_sources

    return report


def report_to_dict(report: LeakReport) -> dict:
    """Convert a LeakReport to a JSON-serializable dict."""
    return {
        "target": report.target,
        "target_type": report.target_type,
        "timestamp": datetime.now().isoformat(),
        "hudson_rock": {
            "total_stealers": len(report.hr_stealers),
            "message": report.hr_message,
            "stealers": [asdict(s) for s in report.hr_stealers],
            "employees": report.hr_employees,
            "users": report.hr_users,
        },
        "proxynova_comb": {
            "total_hits": report.comb_count,
            "entries": [asdict(e) for e in report.comb_entries],
        },
        "leakcheck": {
            "success": report.lc_success,
            "found": report.lc_found,
            "fields": report.lc_fields,
            "sources": [asdict(s) for s in report.lc_sources],
        },
    }
