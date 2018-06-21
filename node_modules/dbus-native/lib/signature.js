// parse signature from string to tree

var match = {
  '{': '}',
  '(': ')'
};

var knownTypes = {};
'(){}ybnqiuxtdsogarvehm*?@&^'.split('').forEach(function(c) {
  knownTypes[c] = true;
});

module.exports = function parseSignature(signature) {
  var index = 0;
  function next() {
    if (index < signature.length) {
      var c = signature[index];
      ++index;
      return c;
    }
    return null;
  }

  function parseOne(c) {
    function checkNotEnd(c) {
      if (!c) throw new Error('Bad signature: unexpected end');
      return c;
    }

    if (!knownTypes[c])
      throw new Error(`Unknown type: "${c}" in signature "${signature}"`);

    var ele;
    var res = { type: c, child: [] };
    switch (c) {
      case 'a': // array
        ele = next();
        checkNotEnd(ele);
        res.child.push(parseOne(ele));
        return res;
      case '{': // dict entry
      case '(': // struct
        while ((ele = next()) !== null && ele !== match[c])
          res.child.push(parseOne(ele));
        checkNotEnd(ele);
        return res;
    }
    return res;
  }

  var ret = [];
  var c;
  while ((c = next()) !== null) ret.push(parseOne(c));
  return ret;
};

const fromTree = function(tree) {
  var res = '';
  for (var i = 0; i < tree.length; ++i) {
    if (tree[i].child.length === 0) {
      res += tree[i].type;
    } else {
      if (tree[i].type === 'a') {
        res += `a${fromTree(tree[i].child)}`;
      } else {
        res += tree[i].type + fromTree(tree[i].child) + match[tree[i].type];
      }
    }
  }
  return res;
};

// command-line test
//console.log(JSON.stringify(module.exports(process.argv[2]), null, 4));
//var tree = module.exports('a(ssssbbbbbbbbuasa{ss}sa{sv})a(ssssssbbssa{ss}sa{sv})a(ssssssbsassa{sv})');
//console.log(tree);
//console.log(fromTree(tree))
