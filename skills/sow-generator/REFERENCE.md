# SOW Generator — Placeholder & Conditional Logic Reference

Claude reads this file when it needs detailed lookup tables during the SOW interview and generation process.

---

## Migration Template Placeholders

### Required Fill-ins

| Placeholder | Description | Example |
|-------------|-------------|---------|
| `#client` | Client company name | Acme Broadcasting |
| `#reseller` | Reseller/dealer company name | Signiant Media |
| `#platform` | Source MAM platform name | Dalet |
| `#date` | Document date | February 25, 2026 |
| `#logo` | Client or project logo | *(manual — not automated)* |

### Optional Sections

| Section | Location | Default |
|---------|----------|---------|
| Exhibit 2: Discovery & Extraction Services | End of document | Exclude unless source platform requires DB reverse-engineering |

---

## Avid Interplay Migration Template Placeholders

### Shared Fill-ins (same as Migration)

| Placeholder | Description | Example |
|-------------|-------------|---------|
| `#client` | Client company name | Acme Broadcasting |
| `#reseller` | Reseller/dealer company name | ASG |
| `#date` | Document date | February 25, 2026 |
| `#logo` | Client or project logo | *(manual — not automated)* |

### Avid-Specific Fill-ins

| Placeholder | Description | Example | "I don't know" |
|-------------|-------------|---------|----------------|
| `#destination` | Destination MAM system | Iconik | Leave as `#destination` |
| `#total_data_size` | Total estimated data size | 150 TB | Leave as `#total_data_size` |
| `#disk_data` | Disk data in TB | 80 | Leave as `#disk_data` |
| `#clip_count` | Approximate online clip count | 250,000 | Leave as `#clip_count` |
| `#lto_data` | LTO tape data size | 70 TB / N/A if none | Leave as `#lto_data` |
| `#archive_system` | Archive system type | FlashNet, SDNA | Leave as `#archive_system` |
| `#free_storage` | Current free storage in TB | 40 | Leave as `#free_storage` |
| `#hypervisor` | Hypervisor setup (see options below) | Client-provided VMWare | Leave as `#hypervisor` |
| `#network` | Network speed (see options below) | 10Gb | Leave as `#network` |

---

## Hypervisor Options

| Answer | Replacement Text | Server Rental |
|--------|-----------------|---------------|
| Client VMWare | `Client-provided VMWare` | No |
| Client Proxmox | `Client-provided Proxmox` | No |
| NSA Proxmox | `NSA-provided Proxmox hardware` | Yes — keep rental note |

**Server rental logic:** If `#hypervisor` = NSA Proxmox, the rental note line stays as-is. If client-provided, remove the server rental note line.

---

## Network Options

| Answer | Replacement Text | Conditional Action |
|--------|------------------|--------------------|
| 10Gb | `10Gb host bus adapter (HBA)` | **Remove** the three caveat lines below |
| 1Gb | `1Gb networking` | Keep all three caveat lines as-is |
| Bonded 1Gb | `Bonded 1Gb connections` | Keep all three caveat lines as-is |
| Don't know | Leave `#network` | Keep all three caveat lines as-is |

### Network Caveat Lines (removed when 10Gb selected)

These three exact lines appear after the Network placeholder and are removed when 10Gb is selected:

1. `Note: 1Gb networking is supported; however, this will significantly increase the overall project timeline and may result in a Change Order`
2. `NSA recommends bonded 1Gb connections minimum or installation of a 10Gb host bus adapter (HBA)`
3. `All NSA-provided systems are equipped with multiple 1Gb and 10Gb network interfaces`

---

## Conditional Logic Summary

### Migration Template
- **Discovery & Extraction = No** → Remove "Exhibit 2: Discovery & Extraction Services (Optional)" section (from heading through `[END]` marker) AND remove the Deliverables reference line containing "If the source #platform system requires database discovery"

### Avid Interplay Template
- **Hypervisor = Client-provided (VMWare or Proxmox)** → Remove line containing "Server rental fees"
- **Network = 10Gb** → Remove the three network caveat lines listed above
- **Any field = "don't know"** → Leave the `#placeholder` text as-is in the document. Report all unfilled placeholders at delivery.
