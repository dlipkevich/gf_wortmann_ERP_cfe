﻿#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	// #wortmann { 
	// Получаем глобальное значение папки с файлами
	// Галфинд_Домнышева 2022/09/19	
	Объект.КаталогЗагрузки = _омОбщегоНазначенияВызовСервера.ПолучитьГлобальноеЗначение("гф_ГлобальныеЗначенияI5Incoming");
	// } #wortmann
КонецПроцедуры

#КонецОбласти 

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура Загрузить(Команда) 
	// #wortmann { 
	// Процедура помещения файлов из выбранного каталога
	// Галфинд_Домнышева 2022/09/19	
	МассивФайлов = НайтиФайлы(Объект.КаталогЗагрузки, "*.xml");		
	ОписанияПередаваемыхФайлов = Новый Массив;
	
	Для каждого Элемент Из МассивФайлов Цикл		 
		Описание = Новый ОписаниеПередаваемогоФайла;
		Описание.Имя = Элемент.ПолноеИмя; 
		ОписанияПередаваемыхФайлов.Добавить(Описание);
	КонецЦикла;
	
	ОписаниеОЗавершении = Новый ОписаниеОповещения("ОбработатьВыборВнешнегоФайла", ЭтотОбъект);
	НачатьПомещениеФайловНаСервер(ОписаниеОЗавершении, , , ОписанияПередаваемыхФайлов, ЭтотОбъект.УникальныйИдентификатор);
	// } #wortmann
КонецПроцедуры  

#КонецОбласти 

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура КаталогЗагрузкиНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	// #wortmann { 
	// Открытие диалога выбора папки при ручном выборе КаталогаЗагрузки
	// Галфинд_Домнышева 2022/09/19
	Режим = РежимДиалогаВыбораФайла.ВыборКаталога; 
	Диалог = Новый ДиалогВыбораФайла(Режим); 
	Диалог.Каталог = ""; 
	Диалог.МножественныйВыбор = Ложь; 
	Диалог.Заголовок = "Выберите каталог"; 
	Если Диалог.Выбрать() Тогда 
		Объект.КаталогЗагрузки = Диалог.Каталог;
	КонецЕсли;
	// } #wortmann
КонецПроцедуры

#КонецОбласти 

#Область СлужебныеПроцедурыИФункции
// #wortmann { 
// Производит вызов процедуры для загрузки файлов из i5 и возвращает массив загруженных файлов. 
// Галфинд_Домнышева 2022/09/19
// 
// Параметры:
//	ДанныеДляЗагрузки - Массив - массив структур с данными загружаемых файлов.
//
// Возвращаемое значение:
//	ФайлыВАрхив - Массив - массив состоящий из значений ПолногоИмениФайла.
&НаСервере
Функция ЗагрузитьНаСервере(ДанныеДляЗагрузки)	
	
	ФайлыВАрхив = Новый Массив;
	ДокументОбъект = РеквизитФормыВЗначение("Объект");
	ФайлыВАрхив = ДокументОбъект.ВыполнитьОбменДанными(ДанныеДляЗагрузки);
	Возврат  ФайлыВАрхив;
	
КонецФункции// } #wortmann

// #wortmann { 
// Формирует Массив структур с данными помещенных файлов и при получении
// массива архивируемых файлов вызывает процедуру ЗаписатьВАрхивУдалитьИзКаталога() 
// Галфинд_Домнышева 2022/09/19
//
// Параметры:
// ПомещенныеФайлы - значение результата, переданное вторым параметром при вызове метода,
// ДополнительныеПараметры - значение, которое было указано при создании объекта оповещения.
//
&НаКлиенте
Процедура ОбработатьВыборВнешнегоФайла(ПомещенныеФайлы, ДополнительныеПараметры) Экспорт
	ФайлыВАрхив = Новый Массив;
	
	ДанныеДляЗагрузки = Новый Массив;
	Для каждого Элемент Из ПомещенныеФайлы Цикл
		НовыйЭлемент = Новый Структура("Адрес, ИмяФайла, ПолноеИмяФайла");
		НовыйЭлемент.Адрес = Элемент.Адрес;
		НовыйЭлемент.ИмяФайла = Элемент.СсылкаНафайл.Файл.Имя;
		НовыйЭлемент.ПолноеИмяФайла = Элемент.СсылкаНафайл.Файл.ПолноеИмя;
		ДанныеДляЗагрузки.Добавить(НовыйЭлемент);
	КонецЦикла;
	
	ФайлыВАрхив = ЗагрузитьНаСервере(ДанныеДляЗагрузки);
	Если ФайлыВАрхив.Количество() > 0 Тогда
		ЗаписатьВАрхивУдалитьИзКаталога(ФайлыВАрхив);
	КонецЕсли;	
КонецПроцедуры// } #wortmann

// #wortmann { 
// Записывает в архив массив загруженных файлов и перемещает их в каталог гф_ГлобальныеЗначенияI5Readed 
// Галфинд_Домнышева 2022/09/19
//
// Параметры:
// ФайлыВАрхив - Массив - массив файлов для помещения в архив
//
&НаКлиенте
Процедура ЗаписатьВАрхивУдалитьИзКаталога(ФайлыВАрхив) 
	
	ДатаАрхивации = ОбщегоНазначенияКлиент.ДатаСеанса();
	ДатаАрхивации = СтрЗаменить(ДатаАрхивации, ":", "_");
	КудаКопируем = _омОбщегоНазначенияКлиентСервер.ПолучитьГлобальноеЗначение("гф_ГлобальныеЗначенияI5Readed");
	ИмяЗИПАрхива = "Архив" + ДатаАрхивации;
	ПолноеИмяАрхива = КудаКопируем + "\" + ИмяЗИПАрхива + ".zip";
	
	МетодСжатия = МетодСжатияZIP.Сжатие;
	УровеньСжатия = УровеньСжатияZIP.Оптимальный;
	МетодШифрования = МетодШифрованияZIP.Zip20; 
	// Создадим объект записи ZIP-архива
	ЗаписьЗИП = Новый ЗаписьZipФайла(ПолноеИмяАрхива, ,
	"" + МетодСжатия + Символы.ПС + УровеньСжатия + Символы.ПС + МетодШифрования,
	МетодСжатия,
	УровеньСжатия,
	МетодШифрования);
	Для каждого Файл Из ФайлыВАрхив Цикл
		// Добавим необходимые файлы в архив
		ЗаписьЗИП.Добавить(Файл, РежимСохраненияПутейZIP.НеСохранятьПути);
	КонецЦикла;
	// Запишем архив на диск
	ЗаписьЗИП.Записать();
	
	Для каждого Файл Из ФайлыВАрхив Цикл
		УдалитьФайлы(Файл);
	КонецЦикла;
	
КонецПроцедуры// } #wortmann

#КонецОбласти