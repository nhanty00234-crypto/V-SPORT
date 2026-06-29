const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const jspPath = path.join(__dirname, '../src/main/webapp/manager/CaLamViec.jsp');
const content = fs.readFileSync(jspPath, 'utf8');

// Find script tags
const scriptStartIdx = content.indexOf('<script>');
const scriptEndIdx = content.indexOf('</script>', scriptStartIdx);

if (scriptStartIdx === -1 || scriptEndIdx === -1) {
    console.error('No script tag found!');
    process.exit(1);
}

let jsCode = content.substring(scriptStartIdx + 8, scriptEndIdx);

// Replace JSTL tags with comments or empty lines
jsCode = jsCode.replace(/<c:forEach[\s\S]*?>/g, '/* c:forEach */');
jsCode = jsCode.replace(/<\/c:forEach>/g, '/* /c:forEach */');
jsCode = jsCode.replace(/<c:out[\s\S]*?\/>/g, '"c_out_value"');

// Replace JSP EL expressions (not preceded by backslash) with a simple number '1'
jsCode = jsCode.replace(/(?<!\\)\${[\s\S]*?}/g, '1');

// Replace JSP scriptlets <%= ... %> with a simple string '"jsp_server_block"'
jsCode = jsCode.replace(/<%=[\s\S]*?%>/g, '"jsp_server_block"');

// Convert escaped JS template literals back to normal ones (\${var} -> ${var})
jsCode = jsCode.replace(/\\(\${)/g, '$1');

// Save to temp file
const tempPath = path.join(__dirname, 'temp_check.js');
fs.writeFileSync(tempPath, jsCode, 'utf8');
console.log('Saved JS code to temp_check.js');

try {
    execSync(`node -c "${tempPath}"`, { stdio: 'inherit' });
    console.log('Syntax check passed!');
} catch (err) {
    console.error('Syntax check failed!');
}
