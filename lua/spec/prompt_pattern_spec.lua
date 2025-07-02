local prompt = require("advanced_git_search.utils.prompt")

describe("parse prompt", function()
    it("extracts nothing although there is an @ sign", function()
        local result = prompt.parse("@")

        assert.are.same(nil, result.query)
        assert.are.same(nil, result.author)

        local result_with_spaces = prompt.parse(" @ ")

        assert.are.same(nil, result_with_spaces.query)
        assert.are.same(nil, result_with_spaces.author)
    end)

    it("extracts query only", function()
        local result = prompt.parse("function() end")

        assert.are.same("function() end", result.query)
        assert.are.same(nil, result.author)
    end)

    it("extracts query only although there is an @ sign", function()
        local result = prompt.parse("function() end @")

        assert.are.same("function() end", result.query)
        assert.are.same(nil, result.author)
    end)

    it("extracts author only", function()
        local result = prompt.parse("@aaron")

        assert.are.same(nil, result.query)
        assert.are.same("aaron", result.author)
    end)

    it("extracts author only with spaces", function()
        local result = prompt.parse("@aaron hallaert")

        assert.are.same(nil, result.query)
        assert.are.same("aaron hallaert", result.author)
    end)

    it("extracts author only with prefix whitespace", function()
        local result = prompt.parse(" @aaron")

        assert.are.same(nil, result.query)
        assert.are.same("aaron", result.author)
    end)

    it("separates query from author", function()
        local result = prompt.parse("Dit is een test @Aaron")

        assert.are.same("Dit is een test", result.query)
        assert.are.same("Aaron", result.author)
    end)

    it("separates query from author without a space", function()
        local result = prompt.parse("Dit is een test@Aaron")

        assert.are.same("Dit is een test", result.query)
        assert.are.same("Aaron", result.author)
    end)
end)
