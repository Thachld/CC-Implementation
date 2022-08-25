({
	afterRender : function(component, helper) {
      this.superAfterRender();
       // Write your custom code here. 
       component.find('result');
      console.log();
    }
})