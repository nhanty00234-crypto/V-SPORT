const fs = require('fs');
const path = require('path');

const tempPath = path.join(__dirname, 'temp_check.js');
if (!fs.existsSync(tempPath)) {
    console.error('Run extract_and_check.js first!');
    process.exit(1);
}

const code = fs.readFileSync(tempPath, 'utf8');

let braceCount = 0;
let parenCount = 0;
let bracketCount = 0;

let lineNum = 1;
let openBracesAt = [];

for (let i = 0; i < code.length; i++) {
    const char = code[i];
    if (char === '\n') {
        lineNum++;
    }
    if (char === '{') {
        braceCount++;
        openBracesAt.push(lineNum);
    } else if (char === '}') {
        braceCount--;
        openBracesAt.pop();
        if (braceCount < 0) {
            console.error(`Extra closing brace '}' at line ${lineNum}`);
        }
    } else if (char === '(') {
        parenCount++;
    } else if (char === ')') {
        parenCount--;
        if (parenCount < 0) {
            console.error(`Extra closing parenthesis ')' at line ${lineNum}`);
        }
    } else if (char === '[') {
        bracketCount++;
    } else if (char === ']') {
        bracketCount--;
        if (bracketCount < 0) {
            console.error(`Extra closing bracket ']' at line ${lineNum}`);
        }
    }
}

console.log(`Braces count diff (should be 0): ${braceCount}`);
console.log(`Parentheses count diff (should be 0): ${parenCount}`);
console.log(`Brackets count diff (should be 0): ${bracketCount}`);

if (braceCount > 0) {
    console.log(`Unclosed braces started at lines: ${openBracesAt.slice(-10).join(', ')}`);
}
