package automationFramework;

import java.util.List;
import java.util.concurrent.TimeUnit;

import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.firefox.FirefoxDriver;
import org.openqa.selenium.support.ui.Select;

public class CheckboxNRadioBtnOperation {

	public static void main(String[] args) throws InterruptedException {
		//Disable browser logs
		System.setProperty(FirefoxDriver.SystemProperty.BROWSER_LOGFILE, "/dev/null");
		WebDriver driver = new FirefoxDriver();
		String URL = "http://toolsqa.wpengine.com/automation-practice-form/";
		// Put an Implicit wait
		driver.manage().timeouts().implicitlyWait(10, TimeUnit.SECONDS);
		driver.get(URL);
		
		//WebElement radioBtn = driver.findElement(By.name("sex"));
		
		List<WebElement> RadioBtn_Sex = driver.findElements(By.name("sex"));
		System.out.println("Check for loop");
		for(WebElement e :RadioBtn_Sex) {
			  System.out.println(e.getAttribute("value"));
		}
	
		boolean bValue = false;
		bValue = RadioBtn_Sex.get(1).isSelected();
		
		if(bValue == false) {
			RadioBtn_Sex.get(1).click();
			System.out.println("Change sex option to female");}
		else {System.out.println("Default value for sex option is female");}

		List<WebElement> RadioBtn_Exp = driver.findElements(By.name("exp"));
		String exp_text= RadioBtn_Exp.get(2).getAttribute("id");
		System.out.println("The exp_text string is " + exp_text);
		driver.findElement(By.id(exp_text)).click();
		
		
		List<WebElement> Chkbox_Profession = driver.findElements(By.name("profession"));
		int iSize = Chkbox_Profession.size();
		for(int i=0; i<iSize ; i++)
		{
			String sValue = Chkbox_Profession.get(i).getAttribute("value");
			if(sValue.equalsIgnoreCase("Automation Tester"))
			{
				System.out.println("The svalue is Automation Tester ");
				Chkbox_Profession.get(i).click();
				break;
			}
		}
		
		WebElement oCheck_Box = driver.findElement(By.cssSelector("input[value='Selenium IDE']"));
		System.out.println("Selenium IDE is selected");
		oCheck_Box.click();
		
		Select oSelect = new Select(driver.findElement(By.id("continents")));
		oSelect.selectByIndex(1);
		Thread.sleep(2000);
		oSelect.selectByVisibleText("Europe");
		
		
		List<WebElement> DropDown_Continental = oSelect.getOptions();
		int iSize2 = DropDown_Continental.size();
		
		for(int i = 0;i<iSize2;i++) {
			String sValue = DropDown_Continental.get(i).getText();
			System.out.println(sValue);
		}
		Select iSelect = new Select(driver.findElement(By.name("selenium_commands")));
		iSelect.selectByIndex(0);
		Thread.sleep(2000);
		iSelect.deselectByIndex(0);
		Thread.sleep(2000);
		iSelect.selectByVisibleText("Navigation Commands");
		Thread.sleep(2000);
		iSelect.deselectByVisibleText("Navigation Commands");
		
		List<WebElement> MultiSelect_Command = iSelect.getOptions();
		int iSize3 = MultiSelect_Command.size();
		
		for(int i = 0;i<iSize3;i++) {
			String sValue = MultiSelect_Command.get(i).getText();
			iSelect.selectByIndex(i);
			System.out.println(sValue);
		}
		
		iSelect.deselectAll();
		
		
		
		
		
		

			
		driver.close();

	}

}