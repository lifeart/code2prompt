export function autofocus(node: HTMLInputElement) {
    const frame = requestAnimationFrame(() => {        
        node.focus();
        node.selectionStart = node.value.length;
        node.selectionEnd = node.value.length;
    });
    return () => {
        cancelAnimationFrame(frame);
    }
}