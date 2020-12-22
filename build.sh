#!/bin/bash

valac --pkg gtk+-3.0 --pkg libsoup-2.4 --pkg gxml-0.20 --pkg gio-2.0 --pkg gstreamer-1.0 main.vala cache.vala api.vala ApplicationHeader.vala 
