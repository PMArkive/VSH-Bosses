# Credit https://github.com/redsunservers/VSH-Rewrite 
# Create build folder
mkdir build
cd build

# Install SourceMod
wget --input-file=http://sourcemod.net/smdrop/1.10/sourcemod-latest-linux
tar -xzf $(cat sourcemod-latest-linux)

# Copy sp and compiler to build dir
cp -r ../addons/sourcemod/scripting addons/sourcemod
cd addons/sourcemod/scripting

# Install Dependencies
wget "https://raw.githubusercontent.com/redsunservers/VSH-Rewrite/master/addons/sourcemod/scripting/include/saxtonhale.inc" --O include/saxtonhale.inc
wget "https://raw.githubusercontent.com/peace-maker/DHooks2/dynhooks/sourcemod_files/scripting/include/dhooks.inc" -O include/dhooks.inc
wget "https://raw.githubusercontent.com/nosoop/SM-TFEconData/master/scripting/include/tf_econ_data.inc" -O include/tf_econ_data.inc
wget "https://raw.githubusercontent.com/FlaminSarge/tf2attributes/master/tf2attributes.inc" -O include/tf2attributes.inc
wget "https://raw.githubusercontent.com/Teamkiller324/Updater/main/scripting/include/updater.inc" -O include/updater.inc