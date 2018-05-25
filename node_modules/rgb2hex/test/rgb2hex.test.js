const rgb2hex = require('../index')
const typeofErrorMessage = 'color has to be type of `string`'
const invalidErrorMessage = (input) => 'given color (' + input + ') isn\'t a valid rgb or rgba color'

describe('rgb2hex should', () => {
    describe('throw an error if input is not typeof string', () => {
        it('[Object] {color: \'something\'}', () => {
            var input = {color: 'something'}
            expect(() => rgb2hex(input)).toThrow(typeofErrorMessage)
        })

        it('[Function] function(){}', () => {
            var input = function(){}
            expect(() => rgb2hex(input)).toThrow(typeofErrorMessage)
        })

        it('[Number] 231', () => {
            var input = 231
            expect(() => rgb2hex(input)).toThrow(typeofErrorMessage)
        })
    })

    describe('throw an error if input is invalid', () => {
        it('notacolor', () => {
            var input = 'notacolor'
            expect(() => rgb2hex(input)).toThrow(invalidErrorMessage(input))
        })

        it('rgba(100, 100)', () => {
            var input = 'rgb(100, 100)'
            expect(() => rgb2hex(input)).toThrow(invalidErrorMessage(input))
        })

        it('rgba(100, 10a0, 200, 300)', () => {
            var input = 'rgba(100, 10a0, 200, 300)'
            expect(() => rgb2hex(input)).toThrow(invalidErrorMessage(input))
        })

        it('rgba(23, 54, 4, -.33)', () => {
            var input = 'rgba(23, 54, 4, -.33)'
            expect(() => rgb2hex(input)).toThrow(invalidErrorMessage(input))
        })
    })

    it('return input if it is already a hex color', () => {
        const input = '#ffffff'
        const parsedValue = rgb2hex(input)

        expect(parsedValue).toHaveProperty('hex')
        expect(parsedValue).toHaveProperty('alpha')
        expect(typeof parsedValue.hex).toEqual('string')
        expect(parsedValue.hex).toEqual('#ffffff')
        expect(typeof parsedValue.alpha).toEqual('number')
        expect(parsedValue.alpha).toEqual(1)
    })

    describe('parse input properly', () => {
        it('converting rgb(210,43,2525)', () => {
            const input = 'rgb(210,43,255)'
            const parsedValue = rgb2hex(input)

            expect(parsedValue).toHaveProperty('hex')
            expect(parsedValue).toHaveProperty('alpha')
            expect(typeof parsedValue.hex).toEqual('string')
            expect(parsedValue.hex).toEqual('#d22bff')
            expect(typeof parsedValue.alpha).toEqual('number')
            expect(parsedValue.alpha).toEqual(1)
        })

        it('converting rgba(12,173,22,.67)', () => {
            const input = 'rgba(12,173,22,.67)'
            const parsedValue = rgb2hex(input)

            expect(parsedValue).toHaveProperty('hex')
            expect(parsedValue).toHaveProperty('alpha')
            expect(typeof parsedValue.hex).toEqual('string')
            expect(parsedValue.hex).toEqual('#0cad16')
            expect(typeof parsedValue.alpha).toEqual('number')
            expect(parsedValue.alpha).toEqual(0.67)
        })

        it('by limiting alpha value to 1', () => {
            var input = 'rgba(12,173,22,12312.67)'
            expect(rgb2hex(input).alpha).not.toBeGreaterThan(1)
        })

    })

    describe('not care about', () => {

        it('rgb or rgba prefix', () => {
            const rgb = 'rgb(0, 0, 0)'
            const rgba = 'rgba(0, 0, 0)'

            expect(rgb2hex(rgb).hex).toEqual(rgb2hex(rgba).hex)
        })

        it('spaces between color numbers', () => {
            const rgbWithSpaces = 'rgb(0, 0, 0)'
            const rgbWithoutSpaces = 'rgba(0,0,0)'

            expect(rgb2hex(rgbWithSpaces).hex).toEqual(rgb2hex(rgbWithoutSpaces).hex)
        })

        it('if alpha value starts with `.` or with `0`', () => {
            const rgbaWithDot = 'rgba(213,12,4,.45)'
            const rgbWitahoutDot = 'rgba(213,12,4,0.45)'

            expect(rgb2hex(rgbaWithDot).alpha).toEqual(rgb2hex(rgbWitahoutDot).alpha)
        })

    })

})