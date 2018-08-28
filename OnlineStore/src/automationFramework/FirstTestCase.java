package automationFramework;

import org.openqa.selenium.WebDriver;
import org.openqa.selenium.firefox.FirefoxDriver;
import org.openqa.selenium.remote.DesiredCapabilities;

public class FirstTestCase {

	public static void main(String[] args) throws InterruptedException {
		//Disable browser logs
		System.setProperty(FirefoxDriver.SystemProperty.BROWSER_LOGFILE, "/dev/null");
		//System.setProperty("webdriver.gecko.driver", "C:\\QA_Project\\geckodriver-v0.21.0-win64\\geckodriver.exe");
		DesiredCapabilities capabilities = DesiredCapabilities.firefox();
		capabilities.setCapability("marionette", true);
		// Create a new instance of the Firefox driver
		WebDriver driver = new FirefoxDriver();
		
        //Launch the Online Store Website
		driver.get("http://www.store.demoqa.com");

        // Print a Log In message to the screen
        System.out.println("Successfully opened the website www.Store.Demoqa.com");

		//Wait for 5 Sec
		Thread.sleep(5000);
		
        // Close the driver
        driver.quit();
    }
}
