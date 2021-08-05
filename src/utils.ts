export const promiseTimeout = (ms: number, promise: Promise<any>) => {
  const timeout = new Promise((_resolve, reject) => {
    const id = setTimeout(() => {
      clearTimeout(id);
      reject('Timed out in ' + ms + 'ms.');
    }, ms);
  });

  return Promise.race([promise, timeout]);
};
