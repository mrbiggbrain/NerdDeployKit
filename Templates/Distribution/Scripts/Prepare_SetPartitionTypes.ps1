# -----------------------------------------------------------
# Include Librarys
# -----------------------------------------------------------
using module .\Config_NDKConfig.psm1
using module .\Logging_Logging.psm1

# -----------------------------------------------------------
# Set System Drive
# -----------------------------------------------------------
[Logging]::Informational("Setting System Drive GPT Type.")
Set-Partition -DriveLetter ([NDKConfig]::SystemDriveLetter) -GptType "{c12a7328-f81f-11d2-ba4b-00a0c93ec93b}"

# -----------------------------------------------------------
# Set OS Drive
# -----------------------------------------------------------
[Logging]::Informational("Setting OS Drive GPT Type.")
Set-Partition -DriveLetter ([NDKConfig]::OSDriveLetter) -GptType "{ebd0a0a2-b9e5-4433-87c0-68b6b72699c7}"

# -----------------------------------------------------------
# Set Recovery Drive
# -----------------------------------------------------------
[Logging]::Informational("Setting Recovery Drive GPT Type.")
Set-Partition -DriveLetter ([NDKConfig]::RecoveryDriveLetter) -GptType "{de94bba4-06d1-4d40-a16a-bfd50179d6ac}"