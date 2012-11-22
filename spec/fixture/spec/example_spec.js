describe("example_spec", function() {
  it("should be here for path loading tests", function() {
    expect(true).toBe(true);
  }
  
  describe("nested_groups", function() {
    it("should contain the full name of nested example", function(){
	    expect(true).toBe(true);
	  })
  })
  
  context('context group', function(){
    it("should be here for nested context", function(){
      expect(true).toBe(true);
    })
  })
})

return describe("return example_spec", function(){
  return it("should have example name with return upfront", function(){
    expect(true).toBe(true);
  })
  
  return context("return context", function(){
    it("should be here for nested context with return", function(){
      expect(true).toBe(true);
    })
  })
})

context("root context", function(){
  describe("nested_group in context", function(){
    it("spec in context", function(){
      expect(true).toBe(true);
    })
  })
})
