﻿#Область ОбработчикиСобытийФормы

&НаСервере
Процедура гф_ПриСозданииНаСервереПосле(Отказ, СтандартнаяОбработка)
	// #wortmann {
	// e1cib/data/Задача.ЗадачаИсполнителя?ref=811dbcee7bda45d711ed0e55a7ad5d31
	// добавление реквизитов на форму
	// Галфинд_Домнышева 2022/08/02
	ТипГруппаФормы = Тип("ГруппаФормы");
	ТипПолеФормы = Тип("ПолеФормы");
	ТипКнопкаФормы = Тип("КнопкаФормы");
	ТипТаблицаФормы = Тип("ТаблицаФормы");
	
	НовыйЭлемент = Элементы.Вставить("гф_СтраницаТоварыВКоробах", ТипГруппаФормы, Элементы.ГруппаСтраницы, 
					Элементы.СтраницаТовары);
	НовыйЭлемент.Вид = ВидГруппыФормы.Страница;
	НовыйЭлемент.Заголовок = "Товары в коробах";
	НовыйЭлемент.Подсказка = "Товары в коробах";
	НовыйЭлемент.Группировка = ГруппировкаПодчиненныхЭлементовФормы.Вертикальная;
	// vvv Галфинд \ Sakovich 23.01.2023
	НовыйЭлемент.ПутьКДаннымЗаголовка = "Объект.гф_ТоварыВКоробах.КоличествоСтрок";
	// ^^^ Галфинд \ Sakovich 23.01.2023 
	
	ТаблицаФормы = Элементы.Вставить("гф_ТоварыВКоробах", ТипТаблицаФормы, Элементы.гф_СтраницаТоварыВКоробах);
	ТаблицаФормы.ПутьКДанным = "Объект.гф_ТоварыВКоробах";
	// #wortmann { 
	// Исправила действие на "ПередУдалением")  
	// e1cib/data/Задача.ЗадачаИсполнителя?ref=811fbcee7bda45d711ed282b494b9fc4
	// Галфинд_Домнышева 2022/08/30
	// #wortmann { 
	// Устанавливаем действие для ТЧ гф_ТоварыВКоробах после удаления строки   
	// e1cib/data/Задача.ЗадачаИсполнителя?ref=811dbcee7bda45d711ed0e55a7ad5d31
	// Галфинд_Домнышева 2022/08/05
	// ТаблицаФормы.УстановитьДействие("ПослеУдаления", "гф_ТоварыВКоробахПослеУдаления");
	// } #wortmann
	ТаблицаФормы.УстановитьДействие("ПередУдалением", "гф_ТоварыВКоробахПередУдалением");
    // } #wortmann
	// vvv Галфинд \ Sakovich 23.01.2023
	ТаблицаФормы.УстановитьДействие("ПриОкончанииРедактирования", "гф_ТоварыВКоробахПриОкончанииРедактирования");
	ТаблицаФормы.УстановитьДействие("ПослеУдаления", "гф_ТоварыВКоробахПослеУдаления");
	// ^^^ Галфинд \ Sakovich 23.01.2023 

	НовыйЭлемент  = Элементы.Добавить("гф_ТоварыВКоробахНомерСтроки", ТипПолеФормы, ТаблицаФормы);
	НовыйЭлемент.Вид = ВидПоляФормы.ПолеВвода;      
	НовыйЭлемент.ПутьКДанным = "Объект.гф_ТоварыВКоробах.НомерСтроки";

	НовыйЭлемент  = Элементы.Добавить("гф_ТоварыВКоробахУпаковочныйЛист", ТипПолеФормы, ТаблицаФормы);
	НовыйЭлемент.Вид = ВидПоляФормы.ПолеВвода;      
	НовыйЭлемент.ПутьКДанным = "Объект.гф_ТоварыВКоробах.УпаковочныйЛист";
	// vvv Галфинд \ Sakovich 23.01.2023
	НовыйЭлемент.УстановитьДействие("ПриИзменении", "гф_ТоварыВКоробахУпаковочныйЛистПриИзменении");
	// ^^^ Галфинд \ Sakovich 23.01.2023 
	
	НовыйЭлемент  = Элементы.Добавить("гф_ТоварыВКоробахАртикул", ТипПолеФормы, ТаблицаФормы);
	НовыйЭлемент.Вид = ВидПоляФормы.ПолеВвода;      
	НовыйЭлемент.ПутьКДанным = "Объект.гф_ТоварыВКоробах.Артикул";
	
	НовыйЭлемент  = Элементы.Добавить("гф_ТоварыВКоробахIDКороба", ТипПолеФормы, ТаблицаФормы);
	НовыйЭлемент.Вид = ВидПоляФормы.ПолеВвода;      
	НовыйЭлемент.ПутьКДанным = "Объект.гф_ТоварыВКоробах.IDКороба";

	НовыйЭлемент  = Элементы.Добавить("гф_ТоварыВКоробахКоличествоПар", ТипПолеФормы, ТаблицаФормы);
	НовыйЭлемент.Вид = ВидПоляФормы.ПолеВвода;      
	НовыйЭлемент.ПутьКДанным = "Объект.гф_ТоварыВКоробах.КоличествоПар";
	
	Команда = Команды.Добавить("гф_КомандаПодборТовара");
	Команда.Действие = "гф_КомандаПодборТовара";

	НовыйЭлемент = Элементы.Вставить("гф_ПодборТовара", ТипКнопкаФормы, ТаблицаФормы.КоманднаяПанель);
	НовыйЭлемент.Заголовок = "Подбор";
	НовыйЭлемент.ИмяКоманды = "гф_КомандаПодборТовара";
	НовыйЭлемент.Вид = ВидКнопкиФормы.КнопкаКоманднойПанели;
		
	НовыйЭлемент = Элементы.Вставить("гф_СтраницаПолучателя", ТипГруппаФормы, Элементы.СтраницаДоставка, 
					Элементы.СтраницыДоставки);
	НовыйЭлемент.Вид = ВидГруппыФормы.ОбычнаяГруппа;
	НовыйЭлемент.Подсказка = "Получатель";
	НовыйЭлемент.Группировка = ГруппировкаПодчиненныхЭлементовФормы.Вертикальная;
    
    НовыйЭлемент = Элементы.Вставить("гф_КонтрагентПолучатель", ТипПолеФормы, Элементы.гф_СтраницаПолучателя);
	НовыйЭлемент.Вид = ВидПоляФормы.ПолеВвода;
	НовыйЭлемент.ПутьКДанным = "Объект.гф_КонтрагентПолучатель";
	
	// Галфинд СадомцевСА 08.02.2024 Перенес условие по Складу отправителю в процедуру
	// e1cib/data/Задача.ЗадачаИсполнителя?ref=8eabb083fed1320811eec66c485bc86b
	//Если ЗначениеЗаполнено(Объект.СкладОтправитель) Тогда 
	     ВидимостьСтраницыТоварыВКоробах();
	//КонецЕсли;
	// } #wortmann       
	
	// #wortmann { 
	// #Монитор логиста Галфинд Окунев 2022/09/05
	НовоеПоле = Элементы.Добавить("гф_ДокументОснование", Тип("ПолеФормы"), Элементы.Склады);
	НовоеПоле.Заголовок			= "Документ основание";
	НовоеПоле.Вид				= ВидПоляФормы.ПолеВвода;
	НовоеПоле.ПутьКДанным		= "Объект.ДокументОснование"; 
	НовоеПоле.ТолькоПросмотр	= Истина;
	Элементы.Переместить(НовоеПоле, Элементы.Склады, Элементы.СкладПолучатель);
	// } #wortmann       

	// #wortmann { 
	// #Монитор логиста Галфинд Окунев 2022/11/18
	НовоеПоле = Элементы.Добавить("гф_ПочтовоеОтправление", Тип("ПолеФормы"), Элементы.ШапкаПраво);
	НовоеПоле.Заголовок			= "Почтовое отправление";
	НовоеПоле.Вид				= ВидПоляФормы.ПолеВвода;
	НовоеПоле.ПутьКДанным		= "Объект.гф_ПочтовоеОтправление"; 
	// } #wortmann      
	
	// #wortmann { 
	// Добавление реквизита "гф_ЗаявкаНаВозврат" 
	// e1cib/data/Задача.ЗадачаИсполнителя?ref=8eabb083fed1320811ee173c8ad022dd
	// Галфинд_Домнышева 2023/06/30
	НовыйЭлемент = Элементы.Вставить("гф_ЗаявкаНаВозврат", ТипПолеФормы, Элементы.ШапкаЛево);
	НовыйЭлемент.Вид = ВидПоляФормы.ПолеВвода;
	НовыйЭлемент.ПутьКДанным = "Объект.гф_ЗаявкаНаВозврат";
	НовыйЭлемент.Видимость = Ложь;
	
	ОпределитьВидимостьЗаявкиНаВозврат(); 
    // } #wortmann
	// ++ Галфинд СадомцевСА 08.02.2024 Реализовано:
	// 2. На вкладке "Товары" необходимо по кнопке "Заполнить" предлагать запуск типовой обработки Обработка.ЗагрузкаТоваровИзВнешнихФайлов. 
	// e1cib/data/Задача.ЗадачаИсполнителя?ref=8eabb083fed1320811eec66c485bc86b
	НоваяКоманда = Команды.Добавить("гф_ЗагрузитьИзВнешнегоФайла");
	НоваяКоманда.Заголовок = "Загрузить из внешнего файла";
	НоваяКоманда.Подсказка = "Загрузить из внешнего файла";
	НоваяКоманда.Действие = "гф_ЗагрузитьИзВнешнегоФайла";
	НоваяКоманда.ИзменяетСохраняемыеДанные = Истина;
	НоваяКоманда.Картинка = БиблиотекаКартинок.ЗагрузкаИзВнешнегоИсточника;

	НовыйЭлемент = Элементы.Вставить("гф_ЗагрузитьИзВнешнегоФайла",
		ТипКнопкаФормы, Элементы.ТоварыГруппаЗаполнить);
	НовыйЭлемент.Заголовок = "Загрузить из внешнего файла";
	НовыйЭлемент.ИмяКоманды = "гф_ЗагрузитьИзВнешнегоФайла";
	// -- Галфинд СадомцевСА 08.02.2024
	
КонецПроцедуры

&НаСервере
Процедура гф_ПослеЗаписиНаСервереПосле(ТекущийОбъект, ПараметрыЗаписи)
	// #wortmann {
	// e1cib/data/Задача.ЗадачаИсполнителя?ref=8129bcee7bda45d711ed9999703af47d
	// При проведении при необходимости автоматически создавать приходные и расходные ордера
	// Галфинд Sakovich 2023/01/24
	ТекущийОбъект.гф_ПроверитьСоздатьОрдераПоПеремещению(ТекущийОбъект, ПараметрыЗаписи); // Галфинд_Домнышева Проц перенесена в МО, 24_04_2023
	// } #wortmann
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

// #wortmann {
// открытие формы подбора УЛ
// e1cib/data/Задача.ЗадачаИсполнителя?ref=811dbcee7bda45d711ed0e55a7ad5d31
// Галфинд_Домнышева 2022/08/02
&НаКлиенте
Процедура гф_КомандаПодборТовара(Команда)
	
	// vvv Галфинд \ Sakovich 23.01.2023
	Если Не (ЗначениеЗаполнено(Объект.Организация) И ЗначениеЗаполнено(Объект.СкладОтправитель)) Тогда
		Если Не ЗначениеЗаполнено(Объект.Организация) Тогда
			ОбщегоНазначенияКлиент.СообщитьПользователю("Не заполнена ""Организация""", ,
			"Организация", "Объект");
		КонецЕсли;
		Если Не ЗначениеЗаполнено(Объект.СкладОтправитель) Тогда
			ОбщегоНазначенияКлиент.СообщитьПользователю("Не заполнен ""Склад-отправитель""", ,
			"СкладОтправитель", "Объект");
		КонецЕсли;
		Возврат;
	КонецЕсли;
	// ^^^ Галфинд \ Sakovich 23.01.2023 
	
	ПараметрыФормы = Новый Структура("СкладУпаковки", Объект.СкладОтправитель);
	// vvv Галфинд \ Sakovich 23.01.2023
	ПараметрыФормы.Вставить("Организация", Объект.Организация);
	ПараметрыФормы.Вставить("ДатаПодбора", ?(ЗначениеЗаполнено(Объект.Дата), Объект.Дата, ТекущаяДата()));
	// ^^^ Галфинд \ Sakovich 23.01.2023
	ОповещениеПодбора = Новый ОписаниеОповещения("ПодборЗавершение", ЭтотОбъект);
	
	ОткрытьФорму("Документ.УпаковочныйЛист.Форма.гф_ФормаПодбора", ПараметрыФормы, ЭтаФорма, , , ,
	ОповещениеПодбора, РежимОткрытияОкнаФормы.БлокироватьОкноВладельца);

КонецПроцедуры// } #wortmann 

// #wortmann {
// заполнение ТЧ гф_ТоварыВКоробах по закрытию формы Подбора 
// e1cib/data/Задача.ЗадачаИсполнителя?ref=811dbcee7bda45d711ed0e55a7ad5d31
// Галфинд_Домнышева 2022/08/02	
&НаКлиенте
Процедура ПодборЗавершение(Результат, ДополнительныеПараметры) Экспорт
	
	Если ЗначениеЗаполнено(Результат) Тогда
		
		МассивСсылок = Новый Массив;
		Для каждого СтруДанных Из Результат Цикл	
			МассивСсылок.Добавить(СтруДанных.УпаковочныйЛист);	
		КонецЦикла;
		
		Если ПроверитьНаличиеВОстаткахПоВыбраннымУЛ(МассивСсылок) Тогда
			
			Для каждого СтруДанных Из Результат Цикл
				
				Если Объект.гф_ТоварыВКоробах.НайтиСтроки(СтруДанных).Количество() = 0 Тогда
					строкаТоваровВКоробах = Объект.гф_ТоварыВКоробах.Добавить();
					ЗаполнитьЗначенияСвойств(строкаТоваровВКоробах, СтруДанных);
					ЗагрузитьТоварыПоУЛ(СтруДанных.УпаковочныйЛист);
				КонецЕсли;
				
			КонецЦикла;
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры// } #wortmann

#КонецОбласти 

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
&ИзменениеИКонтроль("АдресДоставкиНачалоВыбора")
Процедура гф_АдресДоставкиНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	#Вставка
	// #wortmann {
	// изменена процедура выбора адреса, теперь
	// пользователю предоставляется выбор значений Строка или Адрес
	// e1cib/data/Задача.ЗадачаИсполнителя?ref=811dbcee7bda45d711ed0e55a7ad5d31
	// Галфинд_Домнышева 2022/08/02
	СтандартнаяОбработка = Ложь;
	МассивТипов = Новый Массив;
	МассивТипов.Добавить(Тип("Строка"));
	МассивТипов.Добавить(Тип("СправочникСсылка.гф_АдресаДоставки"));	
	КвалификаторСтроки = Новый КвалификаторыСтроки(500);
	ОписаниеТипов = Новый ОписаниеТипов(МассивТипов, КвалификаторСтроки);
	
	СписокТипов = Новый СписокЗначений;
	СписокТипов.ЗагрузитьЗначения(МассивТипов);
	Оповещение = Новый ОписаниеОповещения("ОбработкаВыбораТипаДанных", ЭтотОбъект, Элемент);
	СписокТипов.ПоказатьВыборЭлемента(Оповещение, "Выбор типа данных");
	// } #wortmann
	#КонецВставки
	#Удаление
	ИменаРеквизитовАдресовДоставки = ДоставкаТоваровКлиентСервер.ИменаРеквизитовАдресовДоставки("АдресДоставки");
	
	ДоставкаТоваровКлиент.ОткрытьФормуВыбораАдресаИОбработатьРезультат(
		Элемент,
		Объект,
		ИменаРеквизитовАдресовДоставки,
		СтандартнаяОбработка);
	#КонецУдаления
	
КонецПроцедуры

// #wortmann {
// открытие определенной формы заполнения адреса в зависимости от выбора пользователя
// e1cib/data/Задача.ЗадачаИсполнителя?ref=811dbcee7bda45d711ed0e55a7ad5d31
// Галфинд_Домнышева 2022/08/02
&НаКлиенте
Процедура ОбработкаВыбораТипаДанных(ВыбранныйЭлемент, ДопПараметры) Экспорт
	
	Если ВыбранныйЭлемент.Значение = Неопределено Тогда  
		Возврат;
	КонецЕсли;
	
	Если ВыбранныйЭлемент.Значение = Тип("СправочникСсылка.гф_АдресаДоставки") Тогда
		
		ПараметрыФормы = Новый Структура;
		Отбор = Новый Структура;
		Отбор.Вставить("Владелец", Объект.гф_КонтрагентПолучатель);
		ПараметрыФормы.Вставить("Отбор", Отбор);
		
		ОбработкаВыбора = Новый ОписаниеОповещения("ПриЗакрытииФормыВыбора", ЭтаФорма, "ПодборРеализации");
		
		ОткрытьФорму("Справочник.гф_АдресаДоставки.ФормаВыбора", ПараметрыФормы,
		ЭтаФорма, , , , ОбработкаВыбора);
	Иначе			
		// vvv Галфинд \ Sakovich 03.11.2022
		//ИмяРеквизитаАдресаДоставки = ДоставкаТоваровКлиентСервер.ПолучитьИмяРеквизитаАдресаДоставки(ДопПараметры);
		ИмяРеквизитаАдресаДоставки = гф_ПолучитьИмяРеквизитаАдресаДоставки(ДопПараметры);
		// ^^^ Галфинд \ Sakovich 03.11.2022 
		ДоставкаТоваровКлиент.ОткрытьФормуВыбораАдресаИОбработатьРезультат(
		ДопПараметры,
		Объект,
		ИмяРеквизитаАдресаДоставки);
	КонецЕсли;
	
КонецПроцедуры// } #wortmann

// #wortmann {
// заполняет значение реквизита Адрес согласно выбранному значению Пользователем
// e1cib/data/Задача.ЗадачаИсполнителя?ref=811dbcee7bda45d711ed0e55a7ad5d31
// Галфинд_Домнышева 2022/08/02
&НаКлиенте
Процедура ПриЗакрытииФормыВыбора(Значение, ДопПараметры) Экспорт
    
    Если Значение = Неопределено Тогда  
        Возврат;
    КонецЕсли;
     
    Объект.АдресДоставки = Значение; 
	
КонецПроцедуры// } #wortmann

// #wortmann { 
// вызов процедуры по настройке видимости страницы гф_СтраницаТоварыВКоробах 
// e1cib/data/Задача.ЗадачаИсполнителя?ref=811dbcee7bda45d711ed0e55a7ad5d31
// Галфинд_Домнышева 2022/08/02
&НаКлиенте
Процедура гф_СкладОтправительПриИзмененииПосле(Элемент)
	
	ВидимостьСтраницыТоварыВКоробах();
	
КонецПроцедуры// } #wortmann 

&НаКлиенте
Процедура гф_СкладПолучательПриИзмененииПосле(Элемент)
	
	ВидимостьСтраницыТоварыВКоробах();
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура гф_ПроверитьСоздатьОрдераПоПеремещению(обПеремещение, ПараметрыЗаписи)

	 // ++ Галфинд_Домнышева_24_04_2023 
	 // Процедура перенесена в МО, 24_04_2023
     // -- Галфинд_Домнышева_24_04_2023
	 
КонецПроцедуры

// #wortmann { 
// настройка видимости созданной страницы гф_СтраницаТоварыВКоробах согласно значению доп.реквизита "Товары в коробах" 
// e1cib/data/Задача.ЗадачаИсполнителя?ref=811dbcee7bda45d711ed0e55a7ad5d31
// Галфинд_Домнышева 2022/08/02
&НаСервере
Процедура ВидимостьСтраницыТоварыВКоробах() 
	
	//СкладОбъект = Объект.СкладОтправитель.ПолучитьОбъект();
	//ТоварыВКоробах = ПланыВидовХарактеристик.ДополнительныеРеквизитыИСведения.НайтиПоНаименованию("Товары в коробах"); 
	//ТоварыВКоробахЗначение = СкладОбъект.ДополнительныеРеквизиты.Найти(ТоварыВКоробах);
	//
	//Если ТоварыВКоробахЗначение = Неопределено Тогда
	//	 Элементы.гф_СтраницаТоварыВКоробах.Видимость = Ложь;
	//Иначе
	//	 Элементы.гф_СтраницаТоварыВКоробах.Видимость = Истина;
	//КонецЕсли;
	
	// ++ Галфинд СадомцевСА 08.02.2024 Реализовано:
	// 1. Если в документе Перемещении товаров оба склада не коробные (Товары в коробах =ЛОЖЬ), необходимо скрывать ТЧ Товары в коробах
	// e1cib/data/Задача.ЗадачаИсполнителя?ref=8eabb083fed1320811eec66c485bc86b
	Элементы.гф_СтраницаТоварыВКоробах.Видимость = Истина; // по-умолчанию тч Товары в коробах видна
	Если Не ЗначениеЗаполнено(Объект.СкладОтправитель) Тогда
		Возврат;
	КонецЕсли;
	Если Не ЗначениеЗаполнено(Объект.СкладПолучатель) Тогда
		Возврат;
	КонецЕсли;
	СкладОтправительКоробной = УправлениеСвойствами.ЗначениеСвойства(Объект.СкладОтправитель, "гф_СкладыТоварыВКоробах") = Истина;
	СкладПолучательКоробной = УправлениеСвойствами.ЗначениеСвойства(Объект.СкладПолучатель, "гф_СкладыТоварыВКоробах") = Истина;
	Если НЕ СкладОтправительКоробной И НЕ СкладПолучательКоробной Тогда
		Элементы.гф_СтраницаТоварыВКоробах.Видимость = Ложь;
	КонецЕсли;
	// -- Галфинд СадомцевСА 08.02.2024 Реализовано:
	
КонецПроцедуры// } #wortmann

// #wortmann { 
// заполняет ТЧ Товары 
// e1cib/data/Задача.ЗадачаИсполнителя?ref=811dbcee7bda45d711ed0e55a7ad5d31
// Галфинд_Домнышева 2022/08/02
&НаСервере
Процедура ЗагрузитьТоварыПоУЛ(УпаковочныйЛист)
   	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	УпаковочныйЛистТовары.Номенклатура КАК Номенклатура,
		|	УпаковочныйЛистТовары.Характеристика КАК Характеристика,
		// #wortmann {
		// Подбор осуществляется и по "Назначению"  
		// e1cib/data/Задача.ЗадачаИсполнителя?ref=811fbcee7bda45d711ed282b494b9fc4
		// Галфинд_Домнышева 2022/08/30
		|	УпаковочныйЛистТовары.Назначение КАК Назначение,
		// } #wortmann
		|	УпаковочныйЛистТовары.Количество КАК Количество
		|ИЗ
		|	Документ.УпаковочныйЛист.Товары КАК УпаковочныйЛистТовары
		|ГДЕ
		|	УпаковочныйЛистТовары.Ссылка = &УпаковочныйЛист";
	
	Запрос.УстановитьПараметр("УпаковочныйЛист", УпаковочныйЛист);
		
	РезультатЗапроса = Запрос.Выполнить();
	Выборка = РезультатЗапроса.Выбрать();

	Пока Выборка.Следующий() Цикл
		
		// #wortmann {
		// Подбор осуществляется и по "Назначению"  
		// e1cib/data/Задача.ЗадачаИсполнителя?ref=811fbcee7bda45d711ed282b494b9fc4
		// Галфинд_Домнышева 2022/08/30
		//СтруВыборки = Новый Структура("Номенклатура, Характеристика");
		СтруВыборки = Новый Структура("Номенклатура, Характеристика, Назначение");
		// } #wortmann
		
		ЗаполнитьЗначенияСвойств(СтруВыборки, Выборка);
		
		Если Объект.Товары.НайтиСтроки(СтруВыборки).Количество() = 0 Тогда
			СтрокаТоваров = Объект.Товары.Добавить();
			ЗаполнитьЗначенияСвойств(СтрокаТоваров, Выборка);
			СтрокаТоваров.КоличествоУпаковок = Выборка.Количество;
			
			// #wortmann {
			// Галфинд Sakovich 2022/10/22
			СтрокаТоваров.Количество = Выборка.Количество;
			// } #wortman
			
		ИначеЕсли Объект.Товары.НайтиСтроки(СтруВыборки).Количество() > 0 Тогда	
			Объект.Товары.НайтиСтроки(СтруВыборки)[0].КоличествоУпаковок = 
										Объект.Товары.НайтиСтроки(СтруВыборки)[0].КоличествоУпаковок + Выборка.Количество;	
			// #wortmann {
			// Галфинд Sakovich 2022/10/22
			Объект.Товары.НайтиСтроки(СтруВыборки)[0].Количество = 
										Объект.Товары.НайтиСтроки(СтруВыборки)[0].Количество + Выборка.Количество;	
			// } #wortmann
			
		КонецЕсли;
	КонецЦикла;
	// #wortmann {
	// Добавлена запись НазначениеОтправителя (исходя из стандартной лигики документа)   
	// e1cib/data/Задача.ЗадачаИсполнителя?ref=811fbcee7bda45d711ed282b494b9fc4
	// Галфинд_Домнышева 2022/08/30
	Для Каждого СтрокаТовары Из Объект.Товары Цикл
		Если Не Объект.ПеремещениеПоЗаказам Или СтрокаТовары.КодСтроки = 0 Тогда
			СтрокаТовары.НазначениеОтправителя = СтрокаТовары.Назначение;
		КонецЕсли;
	КонецЦикла;
    // } #wortmann
	
	ПараметрыЗаполненияРеквизитов = Новый Структура;	
	ПараметрыЗаполненияРеквизитов.Вставить("ЗаполнитьПризнакХарактеристикиИспользуются",
											Новый Структура("Номенклатура", "ХарактеристикиИспользуются"));
	// #wortmann {
	// Добавлено заполнение признаков для отображения Назначения (исходя из стандартной лигики документа)   
	// e1cib/data/Задача.ЗадачаИсполнителя?ref=811fbcee7bda45d711ed282b494b9fc4
	// Галфинд_Домнышева 2022/08/30										
	ПараметрыЗаполненияРеквизитов.Вставить("ЗаполнитьПризнакАртикул",
											Новый Структура("Номенклатура", "Артикул"));
	ПараметрыЗаполненияРеквизитов.Вставить("ЗаполнитьПризнакТипНоменклатуры",
											Новый Структура("Номенклатура", "ТипНоменклатуры"));																				
	// } #wortmann										
	НоменклатураСервер.ЗаполнитьСлужебныеРеквизитыПоНоменклатуреВКоллекции(Объект.Товары, ПараметрыЗаполненияРеквизитов);
   
КонецПроцедуры// } #wortmann 

// #wortmann { 
// проверяет номенклатуру по всем УЛ на наличие на складе 
// e1cib/data/Задача.ЗадачаИсполнителя?ref=811dbcee7bda45d711ed0e55a7ad5d31
// Галфинд_Домнышева 2022/08/02
// Параметры:
// МассивВыделенных - Массив из ДокументСсылка.УпаковочныйЛист
// Возвращаемое значение:
// Булево - Истина, если все товары из УЛ есть на выбранном складе.
&НаСервере
Функция ПроверитьНаличиеВОстаткахПоВыбраннымУЛ(МассивВыделенных)	
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	УпаковочныйЛистТовары.Номенклатура КАК Номенклатура,
		|	УпаковочныйЛистТовары.Характеристика КАК Характеристика,
		// #wortmann {
		// Подбор осуществляется и по "Назначению"  
		// e1cib/data/Задача.ЗадачаИсполнителя?ref=811fbcee7bda45d711ed282b494b9fc4
		// Галфинд_Домнышева 2022/08/30
		|	УпаковочныйЛистТовары.Назначение КАК Назначение,
		// } #wortmann
		|	СУММА(УпаковочныйЛистТовары.Количество) КАК Количество,
		|	УпаковочныйЛистТовары.Ссылка КАК Ссылка
		|ПОМЕСТИТЬ ВТ_ТЧ
		|ИЗ
		|	Документ.УпаковочныйЛист.Товары КАК УпаковочныйЛистТовары
		|ГДЕ
		|	УпаковочныйЛистТовары.Ссылка В(&МассивСсылок)
		|
		|СГРУППИРОВАТЬ ПО
		|	УпаковочныйЛистТовары.Номенклатура,
		|	УпаковочныйЛистТовары.Характеристика,
		// #wortmann {
		// Подбор осуществляется и по "Назначению"  
		// e1cib/data/Задача.ЗадачаИсполнителя?ref=811fbcee7bda45d711ed282b494b9fc4
		// Галфинд_Домнышева 2022/08/30
		|	УпаковочныйЛистТовары.Назначение,
		// } #wortmann
		|	УпаковочныйЛистТовары.Ссылка
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ВТ_ТЧ.Номенклатура КАК Номенклатура,
		|	ВТ_ТЧ.Характеристика КАК Характеристика,
		// #wortmann {
		// Подбор осуществляется и по "Назначению"  
		// e1cib/data/Задача.ЗадачаИсполнителя?ref=811fbcee7bda45d711ed282b494b9fc4
		// Галфинд_Домнышева 2022/08/30
		|	ВТ_ТЧ.Назначение КАК Назначение,
		// } #wortmann
		|	СУММА(ВТ_ТЧ.Количество) КАК Количество,
		|	МАКСИМУМ(ЕСТЬNULL(ТоварыНаСкладахОстатки.ВНаличииОстаток, 0)) КАК КоличествоНаСкладе
		|ИЗ
		|	ВТ_ТЧ КАК ВТ_ТЧ
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрНакопления.ТоварыНаСкладах.Остатки(
		|				,
		|				Склад = &Склад
		// #wortmann {
		// Подбор осуществляется и по "Назначению"  
		// e1cib/data/Задача.ЗадачаИсполнителя?ref=811fbcee7bda45d711ed282b494b9fc4
		// Галфинд_Домнышева 2022/08/30
		// |					И (Номенклатура, Характеристика) В
		|					И (Номенклатура, Характеристика, Назначение) В
		// } #wortmann
		|						(ВЫБРАТЬ
		|							ВТ_ТЧ.Номенклатура КАК Номенклатура,
		|							ВТ_ТЧ.Характеристика КАК Характеристика,
		// #wortmann {
		// Подбор осуществляется и по "Назначению"  
		// e1cib/data/Задача.ЗадачаИсполнителя?ref=811fbcee7bda45d711ed282b494b9fc4
		// Галфинд_Домнышева 2022/08/30
		|							ВТ_ТЧ.Назначение КАК Назначение
		// } #wortmann
		|						ИЗ
		|							ВТ_ТЧ КАК ВТ_ТЧ)) КАК ТоварыНаСкладахОстатки
		|		ПО ВТ_ТЧ.Номенклатура = ТоварыНаСкладахОстатки.Номенклатура
		|			И ВТ_ТЧ.Характеристика = ТоварыНаСкладахОстатки.Характеристика
		|
		|СГРУППИРОВАТЬ ПО
		|	ВТ_ТЧ.Номенклатура,
		|	ВТ_ТЧ.Характеристика,
		// #wortmann {
		// Подбор осуществляется и по "Назначению"  
		// e1cib/data/Задача.ЗадачаИсполнителя?ref=811fbcee7bda45d711ed282b494b9fc4
		// Галфинд_Домнышева 2022/08/30
		|	ВТ_ТЧ.Назначение";
	    // } #wortmann
	Запрос.УстановитьПараметр("МассивСсылок", МассивВыделенных);
	Запрос.УстановитьПараметр("Склад", Объект.СкладОтправитель);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Выборка = РезультатЗапроса.Выбрать();

	Заполняем = Истина;
	Пока Выборка.Следующий() Цикл
		Если Выборка.КоличествоНаСкладе < Выборка.Количество Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю("На выбранном складе не хватает номенклатуры " + Выборка.Номенклатура +
			" с характеристикой " + Выборка.Характеристика + " в количестве " + (Выборка.Количество - Выборка.КоличествоНаСкладе));
			Заполняем = Ложь;
			Продолжить;
		КонецЕсли;
	КонецЦикла;
	Возврат Заполняем;
	
КонецФункции// } #wortmann 

// #wortmann {
// 30.08.22  Галфинд_Домнышева
// Внесено изменение в название процедуры
// e1cib/data/Задача.ЗадачаИсполнителя?ref=811fbcee7bda45d711ed282b494b9fc4
// Вызов проц УдалитьТовары при удалении строки из ТЧ гф_ТоварыВКоробах  
// e1cib/data/Задача.ЗадачаИсполнителя?ref=811dbcee7bda45d711ed0e55a7ad5d31
// Галфинд_Домнышева 2022/08/05
&НаКлиенте
Процедура гф_ТоварыВКоробахПередУдалением(Элемент, Отказ)
	// vvv Галфинд \ Sakovich 23.01.2023
	//ТекущиеДанные = Элементы.гф_ТоварыВКоробах.ТекущиеДанные;
	//УпаковочныйЛист = ТекущиеДанные.УпаковочныйЛист;
	//УдалитьТовары(УпаковочныйЛист);
	// ^^^ Галфинд \ Sakovich 23.01.2023 
КонецПроцедуры// } #wortmann

&НаКлиенте
Процедура гф_ТоварыВКоробахПослеУдаления()
	гф_ПересчитатьТЧТоварыПоТоварамВКоробах();
КонецПроцедуры

&НаКлиенте
Процедура гф_ТоварыВКоробахПриОкончанииРедактирования(НоваяСтрока, ОтменаРедактирования)
	ПодключитьОбработчикОжидания("гф_ПересчитатьТчТоварыПоТоварамВКоробах", 0.1, Истина);
КонецПроцедуры

&НаКлиенте
Процедура гф_ПересчитатьТЧТоварыПоТоварамВКоробах() Экспорт
	ОтключитьОбработчикОжидания("гф_ПересчитатьТчТоварыПоТоварамВКоробах");
	Объект.Товары.Очистить();
	Для каждого стрТч Из Объект.гф_ТоварыВКоробах Цикл
		Если ЗначениеЗаполнено(стрТч["УпаковочныйЛист"]) Тогда
			ЗагрузитьТоварыПоУЛ(стрТч["УпаковочныйЛист"]);
		КонецЕсли;
	КонецЦикла;	
КонецПроцедуры

&НаКлиенте
Процедура гф_ТоварыВКоробахУпаковочныйЛистПриИзменении(Элемент)

	ТекИдентификатор = Элементы.гф_ТоварыВКоробах.ТекущаяСтрока;
	СтрокаТч = Объект.гф_ТоварыВКоробах.НайтиПоИдентификатору(ТекИдентификатор);
	Если ЗначениеЗаполнено(СтрокаТч["УпаковочныйЛист"]) Тогда
		ЕстьДублиПоУЛ = гф_ПроверитьДублиПоУЛ(СтрокаТч["УпаковочныйЛист"]);
		Если ЕстьДублиПоУЛ Тогда
			КодУЛ = ОбщегоНазначенияУТВызовСервера.ЗначениеРеквизитаОбъекта(СтрокаТч["УпаковочныйЛист"], "Код");
			ОбщегоНазначенияКлиент.СообщитьПользователю("Упаковочный лист с кодом " + 
			КодУЛ + " уже присутствует в табличной части ""Товары в коробах""");
			СтрокаТч["УпаковочныйЛист"] = "";
			СтрокаТч["Артикул"] = "";
			СтрокаТч["IDКороба"] = "";
			СтрокаТч["КоличествоПар"] = 0;
		Иначе
			ДанныеПоУЛ = гф_ПолучитьДанныеПоУЛ(СтрокаТч["УпаковочныйЛист"]);
			ЗаполнитьЗначенияСвойств(СтрокаТч, ДанныеПоУЛ);
		КонецЕсли;
	Иначе
		СтрокаТч["Артикул"] = "";
		СтрокаТч["IDКороба"] = "";
		СтрокаТч["КоличествоПар"] = 0;
	КонецЕсли;

КонецПроцедуры

&НаСервере
Функция гф_ПроверитьДублиПоУЛ(УпаковочныйЛист)
	ЕстьДубли = Ложь;
	тчТоварыВКоробах = Объект.гф_ТоварыВКоробах.Выгрузить();
	мСтрок = тчТоварыВКоробах.НайтиСтроки(Новый Структура("УпаковочныйЛист", УпаковочныйЛист));
	Если мСтрок.Количество() > 1 Тогда
		ЕстьДубли = Истина;
	КонецЕсли;
	Возврат ЕстьДубли;
КонецФункции // ()

&НаСервере
Функция гф_ПолучитьДанныеПоУЛ(УпаковочныйЛист)
	
	ДанныеПоУЛ = Новый Структура("Артикул, IDКороба, КоличествоПар");
	стрУЛ = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(УпаковочныйЛист,
	Новый Структура("IDКороба, КоличествоПар, Комплектация", "Код", "ВсегоМест", "гф_Комплектация"));
	ЗаполнитьЗначенияСвойств(ДанныеПоУЛ, стрУЛ);
	Комплектация = стрУЛ["Комплектация"];
	Если ЗначениеЗаполнено(Комплектация) Тогда
		ДанныеПоУЛ["Артикул"] = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Комплектация, "Владелец.Артикул");
	КонецЕсли;
	Возврат ДанныеПоУЛ;

КонецФункции // ()


// #wortmann { 
// Удаляем товары из ТЧ Товары при удалении УЛ 
// e1cib/data/Задача.ЗадачаИсполнителя?ref=811dbcee7bda45d711ed0e55a7ad5d31
// Галфинд_Домнышева 2022/08/05
&НаСервере
Процедура УдалитьТовары(УпаковочныйЛист)
   	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	УпаковочныйЛистТовары.Номенклатура КАК Номенклатура,
		|	УпаковочныйЛистТовары.Характеристика КАК Характеристика,
		// #wortmann {
		// Подбор осуществляется и по "Назначению"  
		// e1cib/data/Задача.ЗадачаИсполнителя?ref=811fbcee7bda45d711ed282b494b9fc4
		// Галфинд_Домнышева 2022/08/30
		|	УпаковочныйЛистТовары.Назначение КАК Назначение,
		// } #wortmann
		|	УпаковочныйЛистТовары.Количество КАК Количество
		|ИЗ
		|	Документ.УпаковочныйЛист.Товары КАК УпаковочныйЛистТовары
		|ГДЕ
		|	УпаковочныйЛистТовары.Ссылка = &УпаковочныйЛист";
	
	Запрос.УстановитьПараметр("УпаковочныйЛист", УпаковочныйЛист);
		
	РезультатЗапроса = Запрос.Выполнить();
	Выборка = РезультатЗапроса.Выбрать();

	Пока Выборка.Следующий() Цикл
		// #wortmann {
		// Подбор осуществляется и по "Назначению"  
		// e1cib/data/Задача.ЗадачаИсполнителя?ref=811fbcee7bda45d711ed282b494b9fc4
		// Галфинд_Домнышева 2022/08/30
		//СтруВыборки = Новый Структура("Номенклатура, Характеристика");
		СтруВыборки = Новый Структура("Номенклатура, Характеристика, Назначение");
		// } #wortmann
		ЗаполнитьЗначенияСвойств(СтруВыборки, Выборка);
		
		Если Объект.Товары.НайтиСтроки(СтруВыборки).Количество() > 0 Тогда	
			Объект.Товары.НайтиСтроки(СтруВыборки)[0].КоличествоУпаковок = 
			Объект.Товары.НайтиСтроки(СтруВыборки)[0].КоличествоУпаковок - Выборка.Количество;	
			// #wortmann {
			// Подбор осуществляется и по "Назначению"  
			// e1cib/data/Задача.ЗадачаИсполнителя?ref=811fbcee7bda45d711ed282b494b9fc4
			// Галфинд_Домнышева 2022/08/30
			Объект.Товары.НайтиСтроки(СтруВыборки)[0].Количество = Объект.Товары.НайтиСтроки(СтруВыборки)[0].КоличествоУпаковок;							
			Если Объект.Товары.НайтиСтроки(СтруВыборки)[0].Количество = 0 Тогда
				Индекс = Объект.Товары.НайтиСтроки(СтруВыборки)[0].НомерСтроки;
				Объект.Товары.Удалить(Индекс - 1);
			КонецЕсли;
            // } #wortmann
		КонецЕсли;
	КонецЦикла;
	   
КонецПроцедуры// } #wortmann 

// #wortmann {
// Галфинд Sakovich 2022/11/03
&НаКлиенте
Функция гф_ПолучитьИмяРеквизитаАдресаДоставки(Элемент)
	// см. типовую процедуру в версии 2.5.9.116
	// ДоставкаТоваровКлиентСервер.ПолучитьИмяРеквизитаАдресаДоставки(Элемент)
	Если СтрНайти(Элемент.Имя, "АдресДоставкиПеревозчика") > 0 Тогда
		ИмяРеквизитаАдреса = "АдресДоставкиПеревозчика";
	Иначе
		ИмяРеквизитаАдреса = "АдресДоставки";
	КонецЕсли;
	
	Возврат ИмяРеквизитаАдреса;
	
КонецФункции // } #wortmann

// #wortmann { 
// e1cib/data/Задача.ЗадачаИсполнителя?ref=8eabb083fed1320811ee173c8ad022dd
// Галфинд ДомнышеваКР 2023/06/30
&НаСервере
Процедура ОпределитьВидимостьЗаявкиНаВозврат()

	МассивВиртуальныхСкладов = _омОбщегоНазначенияВызовСервера.ПолучитьГлобальноеЗначениеМассив("гф_ВиртуальныеСклады");
	
	Если МассивВиртуальныхСкладов.Найти(Объект.СкладПолучатель) <> Неопределено
		ИЛИ МассивВиртуальныхСкладов.Найти(Объект.СкладОтправитель) <> Неопределено Тогда 
		 Элементы.гф_ЗаявкаНаВозврат.Видимость = Истина;
	КонецЕсли;
		
КонецПроцедуры// } #wortmann

&НаКлиенте
Процедура гф_ЗагрузитьИзВнешнегоФайла(Команда)
	
	// Галфинд СадомцевСА 08.02.2024
	ПараметрыЗагрузки = РаботаСТабличнымиЧастямиКлиент.ПараметрыЗагрузкиНоменклатуры();
	ПараметрыЗагрузки.Организация = Объект.Организация;
	ПараметрыЗагрузки.Заголовок = РасхожденияКлиент.ТекстЗаголовкаЗагрузкиИзВнешнихФайлов();
	ПараметрыЗагрузки.ПересчитыватьСуммы = Ложь;
	
	Оповещение = Новый ОписаниеОповещения("ЗагрузитьИзВнешнегоФайлаЗавершение", ЭтотОбъект);
	РаботаСТабличнымиЧастямиКлиент.ПоказатьФормуЗагрузкиНоменклатуры(ПараметрыЗагрузки, Оповещение);
	
КонецПроцедуры

&НаКлиенте
Процедура ЗагрузитьИзВнешнегоФайлаЗавершение(АдресЗагруженныхДанных, ДополнительныеПараметры) Экспорт
	
	// Галфинд СадомцевСА 08.02.2024
	Если ЗначениеЗаполнено(АдресЗагруженныхДанных) Тогда
		ПолучитьЗагруженныеТоварыИзХранилища(АдресЗагруженныхДанных);
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ПолучитьЗагруженныеТоварыИзХранилища(АдресТоваровВХранилище)

	// Галфинд СадомцевСА 08.02.2024
	ТоварыИзХранилища = ПолучитьИзВременногоХранилища(АдресТоваровВХранилище);
	
	Для Каждого СтрокаТоваров Из ТоварыИзХранилища Цикл
		СтрокаТЧТовары = Объект.Товары.Добавить();
		ЗаполнитьЗначенияСвойств(СтрокаТЧТовары, СтрокаТоваров,,"КодСтроки");
	КонецЦикла;
	
КонецПроцедуры

#КонецОбласти
