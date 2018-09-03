package automationFramework;

import java.awt.Color;
import java.time.Duration;
import java.util.StringTokenizer;
import java.util.concurrent.TimeUnit;

import org.openqa.selenium.By;
import org.openqa.selenium.NoSuchElementException;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.firefox.FirefoxDriver;
import org.openqa.selenium.support.ui.Wait;
import org.openqa.selenium.support.ui.FluentWait;
import com.google.common.base.Function;


public class FluentWaitFunction1 {

	public static void main(String[] args) throws InterruptedException {
		//Disable browser logs
		System.setProperty(FirefoxDriver.SystemProperty.BROWSER_LOGFILE, "/dev/null");
		WebDriver driver = new FirefoxDriver();
		String URL = "http://toolsqa.wpengine.com/automation-practice-switch-windows/";
		// Put an Implicit wait
		driver.manage().timeouts().implicitlyWait(10, TimeUnit.SECONDS);
		driver.get(URL);
		
		
		FluentWait<WebDriver> wait = new FluentWait<WebDriver>(driver);
		wait.pollingEvery(Duration.ofMillis(250));
		wait.withTimeout(Duration.ofSeconds(60));
		wait.ignoring(NoSuchElementException.class);

		

		Function<WebDriver, Boolean> function = new Function<WebDriver, Boolean>()
		{

				public Boolean apply(WebDriver arg0) {
					WebElement element = arg0.findElement(By.id("colorVar"));
					String color = element.getAttribute("style");
					System.out.println("The color if the button is " + color);
					
					String s1 = color.substring(7, color.length() - 1);
					System.out.println("The color substring button is " + s1);
							
				if(s1.equals("red"))
					{
					return true;
					}
					
				return false;
				}
			};
			
		wait.until(function);
		


			
		driver.close();

	}

}