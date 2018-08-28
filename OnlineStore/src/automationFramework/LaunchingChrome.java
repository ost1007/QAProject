package automationFramework;

import org.openqa.selenium.WebDriver;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.firefox.FirefoxDriver;

public class LaunchingChrome{
	public static void main(String[] args) {
		
		//String exePath = "C:\\Users\\abc\\Desktop\\Server\\chromedriver.exe";
		//System.setProperty("webdriver.chrome.driver", exePath);
		WebDriver driver = new ChromeDriver();
		driver.get("http://toolsqa.wpengine.com/automation-practice-form/");
}
}
