/******************************************************************************
                __               ____                __
               / /   ___  ____ _/ __/_____________ _/ /__
              / /   / _ \/ __ `/ /_/ ___/ ___/ __ `/ / _ \
             / /___/  __/ /_/ / __(__  ) /__/ /_/ / /  __/
            /_____/\___/\__,_/_/ /____/\___/\__,_/_/\___/

    (C)opyright 2025, Leafscale, LLC -  https://www.leafscale.com

    Project: VeeMarker
   Filename: types.v
    Authors: Chris Tusa <chris.tusa@leafscale.com>
    License: <see LICENSE file included with this source code>
Description: Core data types and value representations for template variables

******************************************************************************/

module veemarker

// Any represents any type of value in templates
pub type Any = bool | f64 | int | map[string]Any | string | []Any