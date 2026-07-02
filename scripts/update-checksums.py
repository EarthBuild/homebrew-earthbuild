import urllib.request
import re
import sys

def main():
    # 1. Parse version from Formula/earth.rb
    with open("Formula/earth.rb", "r") as f:
        content = f.read()

    m = re.search(r'version "([0-9.]+)"', content)
    if not m:
        print("Error: version not found in Formula/earth.rb")
        sys.exit(1)
    version = m.group(1)

    print(f"Detected version: {version}")

    # 2. Fetch checksum.asc
    url = f"https://github.com/EarthBuild/earthbuild/releases/download/v{version}/checksum.asc"
    print(f"Fetching checksums from: {url}")
    try:
        with urllib.request.urlopen(url) as response:
            checksums_text = response.read().decode('utf-8')
    except Exception as e:
        print(f"Error fetching checksums: {e}")
        sys.exit(1)

    # 3. Parse hashes
    hashes = {}
    for line in checksums_text.splitlines():
        parts = line.split()
        if len(parts) == 2:
            hashes[parts[1]] = parts[0]

    required_binaries = [
        "earth-darwin-arm64",
        "earth-darwin-amd64",
        "earth-linux-arm64",
        "earth-linux-amd64"
    ]
    for b in required_binaries:
        if b not in hashes:
            print(f"Error: checksum for {b} not found in checksum.asc")
            sys.exit(1)

    # 4. Update sha256 hashes in earth.rb
    for b in required_binaries:
        pattern = rf'(url\s+"https://github\.com/EarthBuild/earthbuild/releases/download/v#{{version}}/{b}"\s+sha256\s+")[a-f0-9]+(")'
        content, count = re.subn(pattern, rf'\g<1>{hashes[b]}\g<2>', content)
        if count == 0:
            print(f"Error: failed to replace sha256 for {b} in Formula/earth.rb")
            sys.exit(1)
        print(f"Updated {b} sha256 to {hashes[b]}")

    with open("Formula/earth.rb", "w") as f:
        f.write(content)

    print("Formula/earth.rb updated successfully!")

if __name__ == "__main__":
    main()
