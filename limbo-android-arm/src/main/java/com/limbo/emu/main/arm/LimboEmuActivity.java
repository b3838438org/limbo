package com.limbo.emu.main.arm;

import android.os.Bundle;

import com.max2idea.android.limbo.main.Config;
import com.max2idea.android.limbo.main.LimboActivity;

public class LimboEmuActivity extends LimboActivity {

	public void onCreate(Bundle bundle){
		Config.enable_ARM = true;
        Config.enable_ARM64 = true;
		Config.enable_KVM = true;
		Config.hd_if_type = "scsi";
		//Config.enableMTTCG = true;
		Config.logFilePath = Config.storagedir + "/limbo/limbo-arm-log.txt";
		Config.machineFolder = Config.machineFolder + "other/arm_machines/";
		
		Config.osImages.put("Debian ARM Linux", "http://limboemulator.weebly.com/debian-arm-linux.html");
		
		super.onCreate(bundle);
	}

	protected void loadQEMULib(){

        try {
            System.loadLibrary("qemu-system-arm");
        } catch (Error ex) {
            System.loadLibrary("qemu-system-aarch64");
        }

    }
}
