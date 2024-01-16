module.exports = {
    lastSync: {
        ref: "646129b59659e2f3509a6fff606a9871b2a68a9c",
        conversionToolVersion: "ef4bcc5c0d0fc3c5ca56cc84212d267b598f9de6"
    },
    upstream: {
        owner: "testing-library",
        repo: "react-testing-library",
        primaryBranch: "main"
    },
    downstream: {
        owner: "roblox",
        repo: "react-testing-library-lua-internal",
        primaryBranch: "main",
        patterns: [
            "src/**/*.lua"
        ]
    },
    renameFiles: [
        [
            (filename) => filename.endsWith(".test.lua"),
            (filename) => filename.replace(".test.lua", ".spec.lua")

        ],
        [
            (filename) => filename.endsWith(".test.ts.lua"),
            (filename) => filename.replace(".test.ts.lua", ".spec.snap.lua")
        ],
        [
            (filename) => filename.endsWith(".ts.lua") && !filename.endsWith(".test.ts.lua"),
            (filename) => filename.replace(".ts.lua", ".spec.snap.lua")
        ],
        [
            (filename) => filename.endsWith(".snap.lua") && !filename.endsWith(".spec.snap.lua"),
            (filename) => filename.replace(".snap.lua", ".spec.snap.lua")
        ],
        [
            (filename) => filename.includes('__tests__') && !filename.includes('.spec.')  && !filename.endsWith('index.lua'),
            (filename) => filename.replace('.lua', '.spec.lua')
        ],
        [
            (filename) => filename.endsWith('index.lua'),
            (filename) => filename.replace('index.lua', 'init.lua')
        ],
        [
            (filename) => filename.endsWith('.d.ts'),
            (filename) => filename.replace('.d.ts', '.ts')
        ]
    ]
}
