describe("example_with_syntax_error_spec", function() {

  it("should have a syntax error", function() {
    var settings = {a: 1, b = 2}; // b = 2 is wrong!
    expect(true).toBe(true);
  });

})