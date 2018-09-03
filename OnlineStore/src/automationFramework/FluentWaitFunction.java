package automationFramework;

import java.time.Duration;
import java.util.concurrent.TimeUnit;

import org.openqa.selenium.By;
import org.openqa.selenium.NoSuchElementException;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.firefox.FirefoxDriver;
import org.openqa.selenium.support.ui.Wait;
import org.openqa.selenium.support.ui.FluentWait;
import com.google.common.base.Function;


public class FluentWaitFunction {

	public static void main(String[] args) throws InterruptedException {
		//Disable browser logs
		System.setProperty(FirefoxDriver.SystemProperty.BROWSER_LOGFILE, "/dev/null");
				
		WebDriver driver = new FirefoxDriver();
		driver.get("http://toolsqa.wpengine.com/automation-practice-switch-windows/");

		FluentWait<WebDriver> wait = new FluentWait<WebDriver>(driver);
		wait.pollingEvery(Duration.ofMillis(250));
		wait.withTimeout(Duration.ofMinutes(2));
		wait.ignoring(NoSuchElementException.class);

		Function<WebDriver, WebElement> function = new Function<WebDriver, WebElement>()
		{
			public WebElement apply(WebDriver arg0) {
				System.out.println("Checking for the element!!");
				WebElement element = arg0.findElement(By.id("target"));
				if(element != null)
				{
					System.out.println("Target element found");
				}
				return element;
			}
		};

		wait.until(function);
	}

}
		


			
		

