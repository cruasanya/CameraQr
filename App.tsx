import { useState } from 'react';
import { StyleSheet, Text, View, Modal, Pressable } from 'react-native';
import { QrView } from './modules/qr-module';
import { OnCodeScanned } from './modules/qr-module/src/QrModuleView';

export default function App() {
  const [scannerVisible, setScannerVisible] = useState(false);
  const [qrArray, setQrArray] = useState<string[]>([])

  const handleCodeScanned = (event: {nativeEvent: OnCodeScanned}) => {
    setQrArray((prevArray) => [...prevArray, event.nativeEvent.data]);
  };

  return (
    <View style={styles.container}> 
      {qrArray.length > 0 ? (
          qrArray.map((code, index) => (
            <Text key={index}>
              {code}
            </Text>
          ))
        ) : (
          <Text>No QR codes scanned yet</Text>
        )}
      <Text>Scan your qr</Text>
      <Pressable style={styles.button} onPress={ () => setScannerVisible(!scannerVisible)}>
        <Text>Start</Text>
      </Pressable>
      <Modal animationType='slide' visible={scannerVisible}>
        <View style={styles.container}>
          <QrView style={{width: "75%", height: "75%" }} onCodeScanned={handleCodeScanned}/>
          <Pressable style={styles.button} onPress={() => setScannerVisible(!scannerVisible)}>
            <Text>Close</Text>
          </Pressable>
        </View>
      </Modal>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
    alignItems: 'center',
    justifyContent: 'center',
  },
  button: {
    borderRadius: 10,
    padding: 15,
    elevation: 2,
    margin: 10,
    backgroundColor: "yellow"
  }
});
