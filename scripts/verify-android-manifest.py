#!/usr/bin/env python3
"""Validate the XML extracted from the final APK with apkanalyzer manifest print."""

import sys
import xml.etree.ElementTree as ET

ANDROID = "{http://schemas.android.com/apk/res/android}"


def verify(path):
    root = ET.parse(path).getroot()
    if root.get("package") != "com.carlos833.dsides":
        raise ValueError("Unexpected Android package")
    application = root.find("application")
    if application is None:
        raise ValueError("Manifest has no application")

    launcher_found = False
    for component in application:
        filters = component.findall("intent-filter")
        exported = component.get(ANDROID + "exported")
        name = component.get(ANDROID + "name", component.tag)
        if filters and exported not in ("true", "false"):
            raise ValueError(
                f"{name}: intent filters require explicit android:exported"
            )
        if component.tag not in ("activity", "activity-alias"):
            continue
        for intent in filters:
            actions = {item.get(ANDROID + "name") for item in intent.findall("action")}
            categories = {
                item.get(ANDROID + "name") for item in intent.findall("category")
            }
            if (
                "android.intent.action.MAIN" in actions
                and "android.intent.category.LAUNCHER" in categories
            ):
                launcher_found = True
                if exported != "true":
                    raise ValueError(f"{name}: launcher requires android:exported=true")
    if not launcher_found:
        raise ValueError("Manifest has no MAIN/LAUNCHER activity")


if __name__ == "__main__":
    try:
        if len(sys.argv) != 2:
            raise ValueError("Usage: verify-android-manifest.py <manifest.xml>")
        verify(sys.argv[1])
    except (ValueError, OSError, ET.ParseError) as error:
        sys.exit(str(error))
    print(
        "Android manifest verified: exported launcher and explicit intent-filter exports"
    )
