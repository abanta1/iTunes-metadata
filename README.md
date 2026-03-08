# iTunes Metadata Tools

[![Build Status](https://img.shields.io/travis/com/your-username/itunes-metadata.svg)](https://travis-ci.com/your-username/itunes-metadata)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Pull Requests Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)

A collection of scripts to manage and enhance metadata for your iTunes music and video library.

## 📖 Description

This project contains a set of scripts designed to solve common metadata problems in an iTunes library. Whether it's fetching high-resolution artwork, updating track information for songs matched by iTunes Match, or applying content ratings, these tools help automate the process of cleaning up and completing your library's metadata.

## ✨ Features

*   **Update Matched Music:** For songs identified as 'Matched AAC audio file', this script searches the iTunes Store and allows you to update local metadata with official store information, including artist, album, track numbers, genre, and release year.
*   **Download Artwork:** Automatically finds and downloads high-resolution (600x600) album art for your music and cover art for your movies and TV shows.
*   **Apply Content Ratings:** Batch applies 'explicit', 'clean', or 'not explicit' ratings to your music files using `AtomicParsley`, based on a prepared input file.
*   **Video Metadata:** Identifies movies and TV shows (m4v, mp4, mkv) in your library, searches for them on the iTunes Store, and downloads the correct artwork.
*   **Store ID Scraper:** A utility script to scrape a list of all country-specific iTunes Storefront IDs.

## 🚀 Getting Started

These instructions will help you get the scripts running on your local machine.

### Prerequisites

Different scripts have different dependencies.

**General:**
*   A Unix-like command-line environment (e.g., macOS, Linux, or WSL for Windows).
*   **AtomicParsley:** A command-line tool for reading and writing MPEG-4 metadata. Several scripts rely on this.

**Ruby Scripts (`iTunesVaultMatch.rb`, `iTart-Vid.rb`):**
*   Ruby environment.
*   Required gems. You can install them via command line:
    ```bash
    sudo gem install json rb-scpt similar_text
    ```

**PHP Script (`iTunes Store ID Getter.php`):**
*   PHP with the `cURL` extension enabled.

**Bash Scripts (`downMatchiTunesalbumart.sh`, `iTapplyRating.sh`):**
*   Standard Unix command-line utilities like `curl`, `wget`, `xxd`, `grep`, and `sed`.

### Installation

1.  Clone the repository:
    ```bash
    git clone https://github.com/your-username/itunes-metadata.git
    ```
2.  Navigate into the project directory:
    ```bash
    cd itunes-metadata
    ```
3.  Make the necessary scripts executable:
    ```bash
    chmod +x iTMM/downMatchiTunesalbumart.sh
    chmod +x iTRatings/iTapplyRating.sh
    chmod +x iTMM/"iTunes Store ID Getter.php"
    ```

## 💻 Usage

*   **`iTunesVaultMatch.rb` (macOS only):**
    Open iTunes and select the 'Matched AAC audio file' tracks you wish to process. Then, run the script from your terminal. It will guide you through finding and applying correct metadata and artwork.
    ```bash
    ruby iTMM/iTunesVaultMatch.rb
    ```

*   **`iTart-Vid.rb`:**
    Before running, edit the script to set the directory containing your video files. It will scan for `.m4v`, `.mp4`, and `.mkv` files and download matching artwork.
    ```bash
    ruby iTMM/iTart-Vid.rb
    ```

*   **`iTapplyRating.sh`:**
    This script applies content ratings from a file named `explicit.txt` that must be placed on your Desktop.
    ```bash
    ./iTRatings/iTapplyRating.sh
    ```
