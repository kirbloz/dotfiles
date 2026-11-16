//.pragma library

// pure parsers for 'nmcli -t' (terse mode)
// no qml stuff

function splitTerse(line) {
    const fields = [];
    let cur = "";
    for (let i = 0; i < line.length; i++) {
        const c = line.charAt(i);
        if (c === "\\" && i + 1 < line.length) {
            i++;
            cur += line.charAt(i);
        } else if (c === ":") {
            fields.push(cur);
            cur = "";
        } else {
            cur += c;
        }
    }
    fields.push(cur);
    return fields;
}

function lines(text) {
    return String(text)
        .split("\n")
        .map(l => l.replace(/\r$/, ""))
        .filter(l => l.trim().length > 0);
}

// nmcli -t -f TYPE,DEVICE,STATE,CONNECTION device
function parseDevices(text) {
    return lines(text).map(l => {
        const f = splitTerse(l);
        return { type: f[0], device: f[1], state: f[2] || "", connection: f[3] || "" };
    });
}

function activeDevice(devices) {
    for (const d of devices) {
        if ((d.type === "wifi" || d.type === "ethernet") && d.state.indexOf("connected") === 0)
            return d;
    }
    return null;
}

// nmcli -t -f IP4.ADDRESS,IP4.GATEWAY device show <if>
function parseIp4(text) {
    let ip = "";
    let gateway = "";
    for (const l of lines(text)) {
        const f = splitTerse(l);
        if (f[0].indexOf("IP4.ADDRESS") === 0 && ip === "")
            ip = (f[1] || "").split("/")[0];
        else if (f[0] === "IP4.GATEWAY")
            gateway = f[1] || "";
    }
    return { ip: ip || "N/A", gateway: gateway || "N/A" };
}

// nmcli -t -f IN-USE,SIGNAL device wifi list ->(0..100) 
function parseInUseSignal(text) {
    for (const l of lines(text)) {
        const f = splitTerse(l);
        if (f[0] === "*")
            return Math.max(0, Math.min(100, parseInt(f[1]) || 0));
    }
    return 0;
}

// nmcli -t -f IN-USE,SSID,SIGNAL,SECURITY device wifi list
function parseWifiList(text) {
    const bySsid = {};
    const order = [];
    for (const l of lines(text)) {
        const f = splitTerse(l);
        if (f.length < 4 || f[1].length === 0)
            continue;
        const entry = {
            ssid: f[1],
            strength: parseInt(f[2]) || 0,
            inUse: f[0] === "*",
            secured: f[3] !== "" && f[3] !== "--"
        };
        const prev = bySsid[entry.ssid];
        if (!prev) {
            bySsid[entry.ssid] = entry;
            order.push(entry.ssid);
        } else if (entry.inUse) {
            prev.inUse = true;
            prev.strength = entry.strength;
        } else if (!prev.inUse) {
            prev.strength = Math.max(prev.strength, entry.strength);
        }
    }
    const list = order.map(k => bySsid[k]);
    list.sort((a, b) => (Number(b.inUse) - Number(a.inUse)) || (b.strength - a.strength));
    return list;
}

// stderr
function cleanError(text) {
    const first = lines(text)[0] || "";
    return first.replace(/^Error:\s*/i, "");
}