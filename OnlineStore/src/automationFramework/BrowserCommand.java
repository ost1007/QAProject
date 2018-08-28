package automationFramework;

import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.firefox.FirefoxDriver;

public class BrowserCommand {

	public static void main(String[] args) throws InterruptedException {
		//Disable browser logs
		System.setProperty(FirefoxDriver.SystemProperty.BROWSER_LOGFILE, "/dev/null");
		WebDriver driver = new FirefoxDriver();
		String URL = "http://toolsqa.wpengine.com/automation-practice-form/";
		driver.get(URL);
		
		driver.findElement(By.partialLinkText("Partial")).click();
		String SubmitText = driver.findElement(By.id("submit")).getTagName();
		System.out.println("Submit btn tag name is " + SubmitText);
		
		
		//driver.findElement(By.name("firstname")).sendKeys("Josh");
		//driver.findElement(By.name("firstname")).sendKeys("Ong");
		//driver.findElement(By.id("submit")).click();
		
		
		//page navigation	
		driver.navigate().to("http://demoqa.com/frames-and-windows/");		
		driver.navigate().back();
		driver.navigate().forward();
		driver.navigate().refresh();
		
		
		
		//basic command to get title,url,page source
		String Title = driver.getTitle();
		String CurrentUrl = driver.getCurrentUrl();
		String PageSource = driver.getPageSource();
		// Storing Page Source length in Int variable
		int pageSourceLength = PageSource.length();
		int titleLength = driver.getTitle().length();
		
		//printout
		System.out.println(Title);
		System.out.println(titleLength);
		System.out.println(CurrentUrl);
		System.out.println(pageSourceLength);
		
		
		driver.close();

	}

}
