﻿
#Область ОбработчикиСобытий

&После("ОбработкаПроверкиЗаполнения")
Процедура гф_ОбработкаПроверкиЗаполнения(Отказ, ПроверяемыеРеквизиты)  
			
	Для ТекИндекс = 0 По гф_ТоварыВКоробах.Количество()-1 Цикл
		
		СтрокаТоварыВКоробах = гф_ТоварыВКоробах[ТекИндекс]; // СтрокаТабличнойЧасти
		
		АдресОшибки = " " + НСтр("ru = 'в строке %НомерСтроки% списка ""Товары в коробах""';
								|en = 'in line %НомерСтроки% of the ""Goods"" list'");
		АдресОшибки = СтрЗаменить(АдресОшибки, "%НомерСтроки%", СтрокаТоварыВКоробах.НомерСтроки);
		
		Если СтрокаТоварыВКоробах.Добавлено И
			Не ЗначениеЗаполнено(СтрокаТоварыВКоробах.ПричинаДобавления) Тогда
			
			ТекстОшибки = НСтр("ru = 'Необходимо указать причину добавления';
								|en = 'Cancellation reason is required'");
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				ТекстОшибки + АдресОшибки,
				ЭтотОбъект,
				ОбщегоНазначенияКлиентСервер.ПутьКТабличнойЧасти("гф_ТоварыВКоробах", СтрокаТоварыВКоробах.НомерСтроки, "ПричинаДобавления"),
				,
				Отказ);
				
		КонецЕсли;
		
		Если СтрокаТоварыВКоробах.Отменено И
			Не ЗначениеЗаполнено(СтрокаТоварыВКоробах.ПричинаОтмены) Тогда
			
			ТекстОшибки = НСтр("ru = 'Необходимо указать причину отмены';
								|en = 'Cancellation reason is required'");
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				ТекстОшибки + АдресОшибки,
				ЭтотОбъект,
				ОбщегоНазначенияКлиентСервер.ПутьКТабличнойЧасти("гф_ТоварыВКоробах", СтрокаТоварыВКоробах.НомерСтроки, "ПричинаОтмены"),
				,
				Отказ);
				
		КонецЕсли;			
		
	КонецЦикла;
	
	Для ТекИндекс = 0 По Товары.Количество()-1 Цикл
		
		СтрокаТовары = Товары[ТекИндекс]; 
		
		АдресОшибки = " " + НСтр("ru = 'в строке %НомерСтроки% списка ""Товары в коробах""';
								|en = 'in line %НомерСтроки% of the ""Goods"" list'");
		АдресОшибки = СтрЗаменить(АдресОшибки, "%НомерСтроки%", СтрокаТоварыВКоробах.НомерСтроки);
		
		Если СтрокаТовары.гф_ДобавленоПоПричине И
			Не ЗначениеЗаполнено(СтрокаТовары.гф_ПричинаДобавления) Тогда
			
			ТекстОшибки = НСтр("ru = 'Необходимо указать причину добавления';
								|en = 'Cancellation reason is required'");
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				ТекстОшибки + АдресОшибки,
				ЭтотОбъект,
				ОбщегоНазначенияКлиентСервер.ПутьКТабличнойЧасти("Товары", СтрокаТовары.НомерСтроки, "гф_ПричинаДобавления"),
				,
				Отказ);
				
		КонецЕсли;
			
    КонецЦикла;
		
КонецПроцедуры

#КонецОбласти