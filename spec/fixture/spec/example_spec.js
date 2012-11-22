describe("example_spec", function() {
  it("should be here for path loading tests", function() {
    expect(true).toBe(true);
  }
  
  describe("nested_groups", function() {
    it("should contain the full name of nested example", function(){
	    expect(true).toBe(true);
	  })
  })
})

return describe("return example_spec", function(){
  return it("should have example name with return upfront", function(){
    expect(true).toBe(true);
  })
})
