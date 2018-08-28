package automationFramework;

import java.io.File;

import org.openqa.selenium.ie.InternetExplorerDriver;
import org.openqa.selenium.ie.InternetExplorerDriverService;

public class LauchingIE {

//	public static void main(String[] args) {
		  //Path to the folder where you have extracted the IEDriverServer executable
				//String service = "C:\\QA_Project\\OnlineStore\\Library\\drivers\\IEDriverServer.exe";
				//System.setProperty("webdriver.ie.driver", service);
				//Using IEDriver3.8.0
//				InternetExplorerDriver  driver = new InternetExplorerDriver();

//				driver.get("http://yahoo.com");

//	}
	public static void main(String[] args) {

		String exePath = "C:\\QA_Project\\OnlineStore\\Library\\drivers\\IEDriverServer.exe";
		InternetExplorerDriverService.Builder serviceBuilder = new InternetExplorerDriverService.Builder();
		serviceBuilder.usingPort(1080); // This specifies that sever should start at this port
		serviceBuilder.usingDriverExecutable(new File(exePath)); //Tell it where you server exe is
		serviceBuilder.withHost("192.168.0.4");
		InternetExplorerDriverService service = serviceBuilder.build(); //Create a driver service and pass it to Internet explorer driver instance
		InternetExplorerDriver driver = new InternetExplorerDriver(service);
		driver.get("http://toolsqa.wpengine.com");
	}

}

