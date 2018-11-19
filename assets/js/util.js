export const groupBy = (objectArray, property) => {
  return objectArray.reduce(function(acc, obj) {
    var key = obj[property];
    if (!acc[key]) {
      acc[key] = [];
    }
    acc[key].push(obj);
    return acc;
  }, {});
};

export const convertToArray = hash => {
  return Object.keys(hash).map(key => {
    return hash[key];
  });
};
